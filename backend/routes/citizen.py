from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Citizen, Hospital, AmbulanceAlert, Severity, db
from utils import haversine, estimate_eta
from datetime import datetime

citizen_bp = Blueprint("citizen", __name__)

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
        
        # Get all hospitals
        all_hospitals = Hospital.query.all()
        print(f"[DirectSOS] Total hospitals in DB: {len(all_hospitals)}")
        for h in all_hospitals:
            print(f"  - {h.id}: oxygen={h.oxygen_available}, lat={h.latitude}, lon={h.longitude}")
        
        hospitals = Hospital.query.filter_by(oxygen_available=True).all()
        print(f"[DirectSOS] Hospitals with oxygen: {len(hospitals)}")
        
        if not hospitals:
            return jsonify(error="No hospitals available with oxygen. Please enable oxygen at your hospital."), 404
        
        # Filter hospitals with valid location data
        hospitals_with_location = [h for h in hospitals if h.latitude and h.longitude]
        print(f"[DirectSOS] Hospitals with location: {len(hospitals_with_location)}")
        
        if not hospitals_with_location:
            return jsonify(error="No hospitals have location data set"), 400
        
        best, best_eta = None, 999
        for h in hospitals_with_location:
            dist = haversine(citizen.latitude, citizen.longitude, h.latitude, h.longitude)
            eta = estimate_eta(dist, severe=True)
            print(f"[DirectSOS] Hospital {h.id}: distance={dist}km, eta={eta}min")
            if eta < best_eta:
                best, best_eta = h, eta
        
        print(f"[DirectSOS] Selected hospital: {best.id if best else None}, eta={best_eta}")
        
        if not best:
            return jsonify(error="Could not calculate suitable hospital"), 400

        alert = AmbulanceAlert(
            citizen_id=citizen.id,
            hospital_id=best.id,
            status="dispatched",
            eta_minutes=best_eta
        )
        db.session.add(alert)
        db.session.commit()

        return jsonify(alert_id=alert.id, eta=best_eta), 201
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

        return jsonify({
            "alert_id": alert.id,
            "eta_minutes": remaining_eta,
            "status": alert.status,
            "created_at": alert.created_at.isoformat(),
            "citizen_latitude": citizen_lat,
            "citizen_longitude": citizen_lon
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