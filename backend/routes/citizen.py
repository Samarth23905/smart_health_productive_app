from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Citizen, Hospital, AmbulanceAlert, Severity, db
from utils import haversine, estimate_eta
from datetime import datetime

citizen_bp = Blueprint("citizen", __name__)

def _hospital_has_resources(h):
    """Check if hospital has ALL meaningful resources available"""
    # Requirement 1: Must have beds (general OR ICU)
    total_beds = (h.total_beds or 0) + (h.icu_beds or 0)
    ward_available = sum((getattr(h, x, 0) or 0) for x in ['general_available','semi_available','private_available','isolation_available'])
    icu_available = sum((getattr(h, x, 0) or 0) for x in ['micu_available','sicu_available','nicu_available','ccu_available','picu_available'])
    
    if total_beds <= 0 and ward_available <= 0 and icu_available <= 0:
        return False
    
    # Requirement 2: Must have oxygen (any form)
    if not (h.oxygen_available or h.central_oxygen or (getattr(h, 'oxygen_cylinders', 0) or 0) > 0):
        return False
    
    # Requirement 3: Must have ambulance
    if not (h.ambulance_available or (getattr(h, 'ambulance_count', 0) or 0) > 0):
        return False
    
    # Requirement 4: Must have at least some staff
    doctors = getattr(h, 'doctors_count', 0) or 0
    nurses = getattr(h, 'nurses_count', 0) or 0
    if doctors <= 0 and nurses <= 0:
        return False
    
    # Requirement 5: Must have at least one diagnostic facility
    diagnostics = [h.lab, h.xray, h.ecg, h.ultrasound, h.ct_scan, h.mri]
    if not any(getattr(h, x, False) for x in ['lab','xray','ecg','ultrasound','ct_scan','mri']):
        return False
    
    # Requirement 6: Must have pharmacy
    if not (h.in_house_pharmacy or h.pharmacy_24x7 or h.essential_drugs):
        return False
    
    return True


@citizen_bp.route("/location", methods=["POST"])
@jwt_required()
def update_citizen_location():
    """Update citizen's current location"""
    try:
        uid = int(get_jwt_identity())
        citizen = Citizen.query.filter_by(user_id=uid).first()
        
        if not citizen:
            return jsonify(msg="Citizen not found"), 404
        
        data = request.get_json()
        latitude = data.get("latitude")
        longitude = data.get("longitude")
        
        if latitude is None or longitude is None:
            return jsonify(msg="Latitude and longitude required"), 400
        
        citizen.latitude = float(latitude)
        citizen.longitude = float(longitude)
        db.session.commit()
        
        print(f"[CitizenLocation] Updated citizen {citizen.id} location: ({latitude}, {longitude})")
        return jsonify(msg="Location updated"), 200
    except Exception as e:
        print(f"[CitizenLocation Error] {e}")
        return jsonify(error=str(e)), 500

@citizen_bp.route("/check-severity", methods=["POST"])
@jwt_required()
def check_severity():
    uid = int(get_jwt_identity())
    citizen = Citizen.query.filter_by(user_id=uid).first()
    
    if not citizen:
        return jsonify(msg="Citizen not found"), 404
    
    data = request.get_json()
    symptoms = data.get("symptoms", "")
    
    # Simple severity scoring algorithm
    severe_keywords = ["chest pain", "difficulty breathing", "loss of consciousness", "severe bleeding"]
    moderate_keywords = ["fever", "cough", "headache", "dizziness"]
    
    symptoms_lower = symptoms.lower()
    severity_level = "mild"
    
    if any(keyword in symptoms_lower for keyword in severe_keywords):
        severity_level = "severe"
    elif any(keyword in symptoms_lower for keyword in moderate_keywords):
        severity_level = "moderate"
    
    severity = Severity(
        citizen_id=citizen.id,
        symptoms=symptoms,
        severity_level=severity_level
    )
    db.session.add(severity)
    db.session.commit()
    
    return jsonify({
        "severity_id": severity.id,
        "severity_level": severity_level,
        "symptoms": symptoms
    }), 201

@citizen_bp.route("/get-hospitals", methods=["GET"])
@jwt_required()
def get_hospitals():
    try:
        from models import User
        hospitals = Hospital.query.all()
        response = []
        for h in hospitals:
            # Skip hospitals with no resources
            if not _hospital_has_resources(h):
                continue

            user = User.query.get(h.user_id)
            response.append({
                "id": h.id,
                "name": user.name if user else f"Hospital {h.id}",
                "phone": h.phone,
                "latitude": h.latitude,
                "longitude": h.longitude,
                "beds_available": h.total_beds,
                "oxygen_available": h.oxygen_available
            })
        return jsonify(response), 200
    except Exception as e:
        return jsonify(error=str(e)), 500

@citizen_bp.route("/direct-sos", methods=["POST"])
@jwt_required()
def direct_sos():
    try:
        uid = int(get_jwt_identity())
        citizen = Citizen.query.filter_by(user_id=uid).first()
        
        if not citizen:
            return jsonify(error="Citizen not found"), 404
        
        if not citizen.latitude or not citizen.longitude:
            return jsonify(error="Citizen location not set. Please update your profile with location."), 400
        
        # Accept resource requirements in request JSON
        data = request.get_json() or {}
        needs_icu = bool(data.get("needs_icu", False))
        needs_ventilator = bool(data.get("needs_ventilator", False))
        needs_oxygen = bool(data.get("needs_oxygen", True))
        needs_ambulance = bool(data.get("needs_ambulance", False))
        # diagnostic requirements (optional)
        needs_lab = bool(data.get("needs_lab", False))
        needs_ct = bool(data.get("needs_ct", False))
        needs_mri = bool(data.get("needs_mri", False))
        max_distance_km = float(data.get("max_distance_km", 50.0))

        # Query hospitals and evaluate per-hospital if they match ALL requested resources
        candidates = Hospital.query.all()
        matching = []
        for h in candidates:
            # skip hospitals lacking geo or with no resources at all
            if h.latitude is None or h.longitude is None:
                continue
            
            # skip hospitals with no meaningful resources
            if not _hospital_has_resources(h):
                continue

            # basic boolean checks
            if needs_oxygen and not bool(h.oxygen_available):
                continue
            if needs_ambulance and not (bool(h.ambulance_available) or (getattr(h, 'ambulance_count', 0) or 0) > 0):
                continue
            if needs_lab and not bool(getattr(h, 'lab', False)):
                continue
            if needs_ct and not bool(getattr(h, 'ct_scan', False)):
                continue
            if needs_mri and not bool(getattr(h, 'mri', False)):
                continue

            # ICU requirement: ensure any ICU available count > 0
            if needs_icu:
                icu_avail = sum((getattr(h, x, 0) or 0) for x in ['micu_available','sicu_available','nicu_available','ccu_available','picu_available'])
                if icu_avail <= 0:
                    continue

            # Ventilator requirement: ensure ventilator counts > 0
            if needs_ventilator:
                vents = sum((getattr(h, x, 0) or 0) for x in ['micu_ventilators','sicu_ventilators','nicu_ventilators','ccu_ventilators','picu_ventilators'])
                if vents <= 0:
                    continue

            # Beds: ensure aggregated available beds > 0
            available_beds = sum((getattr(h, x, 0) or 0) for x in [
                'general_available','semi_available','private_available','isolation_available',
                'micu_available','sicu_available','nicu_available','ccu_available','picu_available'
            ])
            if available_beds <= 0:
                continue

            # Passed checks; compute distance
            dist = haversine(citizen.latitude, citizen.longitude, h.latitude, h.longitude)
            if dist is None:
                continue
            if dist > max_distance_km:
                continue

            matching.append((h, dist))

        if not matching:
            return jsonify(error="No hospital matching all requested resources was found within the search radius."), 404

        # choose nearest matching hospital
        matching.sort(key=lambda x: x[1])
        best, best_dist = matching[0]
        best_eta = estimate_eta(best_dist, severe=True)

        alert = AmbulanceAlert(
            citizen_id=citizen.id,
            hospital_id=best.id,
            status="dispatched",
            eta_minutes=best_eta
        )
        db.session.add(alert)
        db.session.commit()

        return jsonify({
            "alert_id": alert.id,
            "hospital_id": best.id,
            "hospital_name": ( __import__('models').User.query.get(best.user_id).name if best.user_id else None),
            "distance_km": round(best_dist,2),
            "eta_minutes": best_eta
        }), 201
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify(error=str(e)), 500

@citizen_bp.route("/ambulance-status/<int:alert_id>", methods=["GET"])
@jwt_required()
def ambulance_status(alert_id):
    """Get current ambulance status and ETA"""
    try:
        alert = AmbulanceAlert.query.get(alert_id)
        if not alert:
            return jsonify(msg="Invalid alert"), 404

        elapsed = (datetime.utcnow() - alert.created_at).total_seconds() / 60
        remaining_eta = max(alert.eta_minutes - int(elapsed), 0)

        # Update status automatically based on elapsed time
        if remaining_eta == 0 and alert.status == "dispatched":
            alert.status = "arrived"
            db.session.commit()

        # Get citizen location (where ambulance needs to pick up from)
        citizen = Citizen.query.get(alert.citizen_id)
        citizen_lat = citizen.latitude if citizen else 0.0
        citizen_lon = citizen.longitude if citizen else 0.0

        # Get ambulance location (ambulance's current position)
        ambulance_lat = alert.ambulance_latitude if alert.ambulance_latitude is not None else None
        ambulance_lon = alert.ambulance_longitude if alert.ambulance_longitude is not None else None

        # If ambulance location and citizen location are available, check proximity
        try:
            if ambulance_lat is not None and ambulance_lon is not None and citizen and citizen.latitude and citizen.longitude:
                dist_km = haversine(float(ambulance_lat), float(ambulance_lon), float(citizen_lat), float(citizen_lon))
                print(f"[ProximityCheck] Alert {alert.id}: distance_km={dist_km}")
                # If within 0.05 km (~50 meters), mark as arrived
                if dist_km <= 0.05 and alert.status not in ("arrived", "delivered"):
                    alert.status = "arrived"
                    db.session.commit()
        except Exception as e:
            print(f"[ProximityCheck Error] {e}")

        return jsonify({
            "alert_id": alert.id,
            "eta_minutes": remaining_eta,
            "status": alert.status,
            "created_at": alert.created_at.isoformat(),
            "citizen_latitude": citizen_lat,
            "citizen_longitude": citizen_lon,
            "ambulance_latitude": ambulance_lat if ambulance_lat is not None else 0.0,
            "ambulance_longitude": ambulance_lon if ambulance_lon is not None else 0.0
        }), 200
    except Exception as e:
        return jsonify(error=str(e)), 500

@citizen_bp.route("/alerts/<int:alert_id>/complete", methods=["PUT"])
@jwt_required()
def complete_alert(alert_id):
    """Mark an alert as completed when ambulance arrives at hospital"""
    try:
        uid = int(get_jwt_identity())
        print(f"[CompleteAlert] User ID from JWT: {uid}")
        
        # Try to get citizen
        citizen = Citizen.query.filter_by(user_id=uid).first()
        print(f"[CompleteAlert] Looking for citizen with user_id={uid}, Found: {citizen}")
        
        if not citizen:
            # If no citizen found, try to get from alert directly
            alert = AmbulanceAlert.query.get(alert_id)
            if alert:
                print(f"[CompleteAlert] Found alert {alert_id}, citizen_id={alert.citizen_id}")
                citizen = Citizen.query.get(alert.citizen_id)
                print(f"[CompleteAlert] Got citizen from alert: {citizen}")
        
        if not citizen:
            print(f"[CompleteAlert] Still no citizen found!")
            return jsonify(msg="Citizen not found"), 404
        
        alert = AmbulanceAlert.query.get(alert_id)
        if not alert:
            return jsonify(msg="Alert not found"), 404
        
        print(f"[CompleteAlert] Alert {alert_id}: citizen_id={alert.citizen_id}, user citizen_id={citizen.id}")
        
        # Verify this alert belongs to the current citizen
        if alert.citizen_id != citizen.id:
            return jsonify(msg="Unauthorized"), 403
        
        # Mark as delivered
        alert.status = "delivered"
        alert.delivered_at = datetime.utcnow()
        db.session.commit()
        
        print(f"[CompleteAlert] Alert {alert_id} marked as delivered successfully")
        return jsonify({
            "message": "Alert marked as completed",
            "alert_id": alert_id,
            "status": alert.status,
            "delivered_at": alert.delivered_at.isoformat()
        }), 200
    
    except Exception as e:
        print(f"[CompleteAlert Error] {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify(error=str(e)), 500