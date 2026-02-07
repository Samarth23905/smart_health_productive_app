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


# Symptom to Hospital Requirements Mapping
SYMPTOM_TO_REQUIREMENTS = {
    # Cardiac/Respiratory
    "chest pain": {"icu": True, "ccu": True, "oxygen": True, "ecg": True, "lab": True, "specialty": "Cardiology"},
    "chest pain or pressure": {"icu": True, "ccu": True, "oxygen": True, "ecg": True, "lab": True, "specialty": "Cardiology"},
    "breathlessness": {"oxygen": True, "icu": True, "ventilator": True, "specialty": "Pulmonology"},
    "shortness of breath": {"oxygen": True, "icu": True, "ventilator": True, "specialty": "Pulmonology"},
    "getting breathless easily": {"oxygen": True, "icu": True, "ventilator": True},
    "trouble breathing lying": {"oxygen": True, "icu": True, "ventilator": True},
    "waking breathless": {"oxygen": True, "icu": True, "ventilator": True},
    "heart attack": {"icu": True, "ccu": True, "oxygen": True, "ecg": True, "cathlab": True, "specialty": "Cardiology"},
    "heart beating fast": {"ecg": True, "oxygen": True, "lab": True},
    "feeling your heart beating fast or irregularly": {"ecg": True, "oxygen": True, "lab": True},
    "fainting": {"icu": True, "ecg": True, "oxygen": True},
    "bluish lips": {"oxygen": True, "icu": True, "ventilator": True},
    "bluish lips or fingers": {"oxygen": True, "icu": True, "ventilator": True},
    "stroke": {"icu": True, "ct_scan": True, "mri": True, "lab": True, "specialty": "Neurology"},

    # Trauma
    "severe bleeding": {"oxygen": True, "lab": True, "xray": True, "surgery": True, "blood_bank": True},
    "fracture": {"xray": True, "orthopedic": True},
    "trauma": {"icu": True, "oxygen": True, "surgery": True, "xray": True},

    # Infectious
    "fever": {"isolation": True, "lab": True, "oxygen": True},
    "cough": {"isolation": True, "lab": True, "oxygen": True},
    "mucus cough": {"isolation": True, "lab": True, "oxygen": True},
    "blood cough": {"isolation": True, "lab": True, "oxygen": True, "xray": True},
    "covid": {"isolation": True, "oxygen": True, "ventilator": True, "lab": True},

    # Neurological
    "seizure": {"icu": True, "neuro_monitor": True, "lab": True},
    "seizures": {"icu": True, "neuro_monitor": True, "lab": True},
    "headache": {"ct_scan": True, "lab": True},
    "blacking out": {"icu": True, "ct_scan": True, "lab": True},
    "unconsciousness": {"icu": True, "oxygen": True, "ventilator": True},
    "weakness limbs": {"icu": True, "lab": True},
    "numbness": {"ct_scan": True, "mri": True, "lab": True},
    "trouble speaking": {"ct_scan": True, "mri": True, "lab": True},
    "blurred vision": {"ct_scan": True, "lab": True},
    "difficulty walking": {"icu": True, "lab": True},

    # Gastrointestinal
    "severe abdominal pain": {"surgery": True, "lab": True, "ultrasound": True, "ct_scan": True},
    "vomiting": {"lab": True, "iv_setup": True},
    "feeling nausea": {"lab": True, "oxygen": True},
    "burning chest": {"lab": True, "ecg": True},
    "stomach pain": {"ultrasound": True, "ct_scan": True, "lab": True},
    "loose motions": {"lab": True, "isolation": True},
    "constipation": {"ultrasound": True, "lab": True},

    # Other General
    "severe injury": {"icu": True, "oxygen": True, "surgery": True, "xray": True},
    "poisoning": {"icu": True, "lab": True, "stomach_wash": True},
    "allergy": {"icu": True, "oxygen": True},
    "burn": {"surgery": True, "oxygen": True, "icu": True},
    "dizziness": {"lab": True, "ecg": True},
}


def _hospital_has_resource(hospital, resource_name):
    """Check if hospital has a specific resource"""
    resource_map = {
        "icu": lambda h: (getattr(h, 'icu_beds', 0) or 0) > 0 or sum((getattr(h, x, 0) or 0) for x in ['micu_available','sicu_available','nicu_available','ccu_available','picu_available']) > 0,
        "ccu": lambda h: (getattr(h, 'ccu_available', 0) or 0) > 0,
        "micu": lambda h: (getattr(h, 'micu_available', 0) or 0) > 0,
        "sicu": lambda h: (getattr(h, 'sicu_available', 0) or 0) > 0,
        "nicu": lambda h: (getattr(h, 'nicu_available', 0) or 0) > 0,
        "oxygen": lambda h: bool(h.oxygen_available) or bool(h.central_oxygen) or (getattr(h, 'oxygen_cylinders', 0) or 0) > 0,
        "ventilator": lambda h: sum((getattr(h, x, 0) or 0) for x in ['micu_ventilators','sicu_ventilators','nicu_ventilators','ccu_ventilators','picu_ventilators']) > 0,
        "ecg": lambda h: bool(getattr(h, 'ecg', False)),
        "xray": lambda h: bool(getattr(h, 'xray', False)),
        "ct_scan": lambda h: bool(getattr(h, 'ct_scan', False)),
        "mri": lambda h: bool(getattr(h, 'mri', False)),
        "lab": lambda h: bool(getattr(h, 'lab', False)),
        "ultrasound": lambda h: bool(getattr(h, 'ultrasound', False)),
        "isolation": lambda h: (getattr(h, 'isolation_available', 0) or 0) > 0,
        "surgery": lambda h: bool(getattr(h, 'operation_theater', False)),
        "cathlab": lambda h: bool(getattr(h, 'catheterization_lab', False)),
        "blood_bank": lambda h: bool(getattr(h, 'blood_bank', False)),
        "neuro_monitor": lambda h: bool(getattr(h, 'neuro_monitor', False)),
        "iv_setup": lambda h: bool(getattr(h, 'iv_therapy', False)),
        "stomach_wash": lambda h: bool(getattr(h, 'stomach_wash', False)),
        "orthopedic": lambda h: bool(getattr(h, 'orthopedic_dept', False)),
    }
    
    if resource_name in resource_map:
        try:
            return resource_map[resource_name](hospital)
        except:
            return False
    return False


@citizen_bp.route("/hospitals-by-severity/<int:severity_id>", methods=["GET"])
@jwt_required()
def get_hospitals_by_severity(severity_id):
    """Get hospitals ranked by symptom severity and requirements match"""
    try:
        uid = int(get_jwt_identity())
        citizen = Citizen.query.filter_by(user_id=uid).first()
        
        if not citizen:
            return jsonify(error="Citizen not found"), 404
        
        # Get severity record
        severity = Severity.query.get(severity_id)
        if not severity:
            return jsonify(error="Severity record not found"), 404
        
        if severity.citizen_id != citizen.id:
            return jsonify(error="Unauthorized"), 403
        
        # Parse symptoms: prefer structured `symptom_details` JSON when present
        symptoms_text = (severity.symptoms or "")
        symptoms_list = []
        try:
            details = getattr(severity, 'symptom_details', None)
            if details:
                # symptom_details may already be a dict or a JSON string
                if isinstance(details, str):
                    import json
                    try:
                        details = json.loads(details)
                    except Exception:
                        details = None

            if details and isinstance(details, dict):
                # Use keys from symptom_details (these are the canonical symptom names)
                symptoms_list = [k.strip().lower() for k in details.keys() if k and k.strip()]
                symptoms_source = 'symptom_details'
            else:
                # Fallback: split the raw symptoms string (frontend may use '|' or ',')
                raw = symptoms_text or ""
                delim = '|' if '|' in raw else ','
                symptoms_list = [s.split('(')[0].strip().lower() for s in raw.split(delim) if s.strip()]
                symptoms_source = 'symptoms_text'
        except Exception as e:
            print(f"[HospitalsBySeverity] Error parsing symptoms: {e}")
            symptoms_list = []

        # Collect all required resources from symptoms
        required_resources = set()
        symptom_matches = {}

        for symptom in symptoms_list:
            symptom = symptom.strip()
            if not symptom:
                continue

            # symptom already normalized (lowercase, no trailing details)
            symptom_name = symptom
            print(f"[HospitalsBySeverity] Processing symptom (from {symptoms_source}): '{symptom_name}'")

            # Try exact match first
            if symptom_name in SYMPTOM_TO_REQUIREMENTS:
                reqs = SYMPTOM_TO_REQUIREMENTS[symptom_name]
                symptom_matches[symptom_name] = reqs
                print(f"[HospitalsBySeverity] Exact match found for '{symptom_name}': {reqs}")
                for key in reqs:
                    if key != "specialty":
                        required_resources.add(key)
            else:
                # Try partial match
                found = False
                for mapped_symptom, reqs in SYMPTOM_TO_REQUIREMENTS.items():
                    if symptom_name in mapped_symptom or mapped_symptom in symptom_name:
                        symptom_matches[symptom_name] = reqs
                        print(f"[HospitalsBySeverity] Partial match found: '{symptom_name}' -> '{mapped_symptom}'")
                        for key in reqs:
                            if key != "specialty":
                                required_resources.add(key)
                        found = True
                        break

                if not found:
                    print(f"[HospitalsBySeverity] No match found for symptom: '{symptom_name}'")
        
        # Query all hospitals
        hospitals = Hospital.query.all()
        ranked_hospitals = []

        print(f"[HospitalsBySeverity] Processing {len(hospitals)} hospitals")
        print(f"[HospitalsBySeverity] Citizen location: ({citizen.latitude}, {citizen.longitude})")
        print(f"[HospitalsBySeverity] Severity max_severity: {severity.max_severity}")
        print(f"[HospitalsBySeverity] Raw symptoms: {symptoms_text}")
        print(f"[HospitalsBySeverity] Parsed symptoms list: {symptoms_list}")
        print(f"[HospitalsBySeverity] Symptom matches: {symptom_matches}")
        print(f"[HospitalsBySeverity] Required resources: {required_resources}")

        for hospital in hospitals:
            # Skip hospitals without location
            if hospital.latitude is None or hospital.longitude is None:
                print(f"[HospitalsBySeverity] Skipping hospital {hospital.id}: No location")
                continue

            # Skip hospitals with no meaningful resources
            if not _hospital_has_resources(hospital):
                print(f"[HospitalsBySeverity] Skipping hospital {hospital.id}: No resources")
                continue

            # Calculate distance
            distance_km = 0.0
            if citizen.latitude and citizen.longitude:
                dist_result = haversine(citizen.latitude, citizen.longitude, hospital.latitude, hospital.longitude)
                if dist_result:
                    distance_km = round(dist_result, 2)

            # Calculate match score (ROBUST ALGORITHM)
            match_score = 0
            max_score = 0
            reasons = []

            # 1. Weighted resource availability (60 points max)
            # Critical resources like ventilators, ICU, CCU worth more than basic diagnostics
            if required_resources:
                resource_weights = {
                    "icu": 2.0,           # Critical for severe cases
                    "ventilator": 2.0,    # Life-saving equipment
                    "ccu": 2.0,           # Cardiac critical
                    "oxygen": 1.5,        # Essential life support
                    "isolation": 1.5,     # For infectious diseases
                    "surgery": 2.0,       # Critical for trauma
                    "blood_bank": 1.5,    # Critical for trauma/surgery
                    "ecg": 1.0,           # Important cardiac diagnostic
                    "lab": 1.0,           # Standard diagnostic
                    "xray": 0.8,          # Standard diagnostic
                    "ct_scan": 0.9,       # Advanced diagnostic
                    "mri": 0.9,           # Advanced diagnostic
                    "ultrasound": 0.7,    # Standard diagnostic
                }

                total_weight = sum(resource_weights.get(r, 0.5) for r in required_resources)
                resources_matched = 0
                weighted_match = 0

                for resource in required_resources:
                    if _hospital_has_resource(hospital, resource):
                        resources_matched += 1
                        weighted_match += resource_weights.get(resource, 0.5)

                if total_weight > 0:
                    resource_score = (weighted_match / total_weight) * 60
                    match_score += resource_score
                max_score += 60
                reasons.append(f"Resources: {resources_matched}/{len(required_resources)} match")
            else:
                max_score += 60

            # 2. Enhanced severity matching (25 points)
            max_sev = severity.max_severity or "low"
            if max_sev == "severe":
                icu_available = sum((getattr(hospital, x, 0) or 0) for x in ['micu_available','sicu_available','nicu_available','ccu_available','picu_available'])
                if icu_available > 8:
                    match_score += 25
                    reasons.append(f"Excellent ICU ({icu_available} beds)")
                elif icu_available > 4:
                    match_score += 20
                    reasons.append(f"Good ICU ({icu_available} beds)")
                elif icu_available > 0:
                    match_score += 12
                    reasons.append(f"Limited ICU ({icu_available} beds)")
                else:
                    match_score += 5
            elif max_sev == "moderate":
                beds = sum((getattr(hospital, x, 0) or 0) for x in ['general_available','semi_available','private_available','isolation_available'])
                if beds > 30:
                    match_score += 22
                    reasons.append(f"Excellent beds ({beds})")
                elif beds > 15:
                    match_score += 18
                    reasons.append(f"Good beds ({beds})")
                elif beds > 0:
                    match_score += 12
                else:
                    match_score += 5
            else:  # mild/low
                match_score += 15
                reasons.append("Suitable for mild cases")
            max_score += 25

            # 3. Equipment & facilities quality bonus (15 points)
            facility_score = 0
            facility_items = [
                ("central_oxygen", 2),
                ("icu_trained_staff", 2),
                ("emergency_24x7", 2),
                ("defibrillator", 1.5),
                ("blood_bank", 1.5),
                ("pharmacy_24x7", 1.5),
                ("anesthetist_available", 1.5),
                ("lab", 1),
                ("mri", 1),
                ("ct_scan", 1),
            ]

            for attr, points in facility_items:
                if getattr(hospital, attr, False):
                    facility_score += points

            facility_score = min(15, facility_score)
            match_score += facility_score
            max_score += 15

            # 4. Bed availability & utilization (10 points)
            total_available = sum((getattr(hospital, x, 0) or 0) for x in [
                'general_available','semi_available','private_available','isolation_available',
                'micu_available','sicu_available','nicu_available','ccu_available','picu_available'
            ])

            if total_available > 0:
                bed_score = min(10, max(1, total_available / 12))
                match_score += bed_score
                reasons.append(f"{total_available} beds available")
            max_score += 10

            # 5. Distance scoring (5 points - degrading with distance)
            distance_score = 0
            if distance_km < 5:
                distance_score = 5
                reasons.append(f"Very close ({distance_km}km)")
            elif distance_km < 10:
                distance_score = 3
                reasons.append(f"Close ({distance_km}km)")
            elif distance_km < 20:
                distance_score = 1
            match_score += distance_score
            max_score += 5

            # Calculate final percentage
            match_percentage = int((match_score / max_score) * 100) if max_score > 0 else 0

            # Get hospital user info
            from models import User
            hospital_user = User.query.get(hospital.user_id)
            hospital_name = hospital_user.name if hospital_user else f"Hospital {hospital.id}"

            hospital_data = {
                "id": hospital.id,
                "name": hospital_name,
                "match_percentage": match_percentage,
                "match_score": int(match_score),
                "phone": hospital.phone,
                "latitude": hospital.latitude,
                "longitude": hospital.longitude,
                "distance_km": distance_km,
                "beds_available": total_available,
                "oxygen_available": hospital.oxygen_available,
                "icu_available": (getattr(hospital, 'icu_beds', 0) or 0) > 0,
                "recommendation": " | ".join(reasons[:3]) if reasons else "Beds and resources available",
                "rank_badge": "🥇" if match_percentage >= 80 else ("🥈" if match_percentage >= 60 else "🥉")
            }

            print(f"[HospitalsBySeverity] Hospital {hospital.id} ({hospital_name}): match={match_percentage}% (score={int(match_score)}/{max_score}), distance={distance_km}km, reasons={reasons}")
            ranked_hospitals.append(hospital_data)
        
        # Sort by match percentage (descending)
        ranked_hospitals.sort(key=lambda x: x["match_percentage"], reverse=True)
        
        return jsonify({
            "severity_id": severity_id,
            "symptoms": symptoms_text,
            "severity_level": severity.severity_level,
            "hospitals": ranked_hospitals[:10]  # Return top 10
        }), 200
    
    except Exception as e:
        print(f"[HospitalsBySeverity Error] {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify(error=str(e)), 500