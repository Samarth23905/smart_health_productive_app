from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Citizen, Hospital, AmbulanceAlert
import logging
import traceback

hospital_bp = Blueprint("hospital", __name__)
logger = logging.getLogger(__name__)

@hospital_bp.route("/cases", methods=["GET"])
@jwt_required()
def hospital_cases():
    try:
        uid = int(get_jwt_identity())  # Parse string to int
        logger.info(f"[HospitalCases] User ID: {uid}")
        user = User.query.get(uid)
        
        if not user or user.role != "hospital":
            logger.warning(f"[HospitalCases] Unauthorized - User {uid}")
            return jsonify(msg="Unauthorized"), 403

        # Get hospital record
        hospital = Hospital.query.filter_by(user_id=uid).first()

        if not hospital:
            logger.warning(f"[HospitalCases] Hospital not found for user {uid}")
            return jsonify([]), 200

        logger.info(f"[HospitalCases] Hospital ID: {hospital.id}")
        
        # Fetch ambulance alerts for this hospital (excluding delivered/completed)
        alerts = AmbulanceAlert.query.filter_by(
            hospital_id=hospital.id
        ).filter(AmbulanceAlert.status != 'delivered').order_by(AmbulanceAlert.created_at.desc()).all()

        logger.info(f"[HospitalCases] Found {len(alerts)} alerts for hospital {hospital.id}")
        response = []

        for alert in alerts:
            citizen = Citizen.query.get(alert.citizen_id)
            if not citizen:
                logger.warning(f"[HospitalCases] Citizen not found for alert {alert.id}")
                continue
                
            citizen_user = User.query.get(citizen.user_id)
            if not citizen_user:
                logger.warning(f"[HospitalCases] User not found for citizen {citizen.id}")
                continue

            response.append({
                "id": alert.id,
                "alert_id": alert.id,
                "name": citizen_user.name,
                "phone": citizen.phone,
                "sex": citizen.sex,
                # Symptoms & severity can come from severity table later
                "symptoms": "Reported via severity form",
                "severity": "Auto / User reported",
                "eta": alert.eta_minutes,
                "status": alert.status,
                # Ambulance location (real-time)
                "ambulance_latitude": alert.ambulance_latitude or 0.0,
                "ambulance_longitude": alert.ambulance_longitude or 0.0,
                # Hospital location
                "hospital_latitude": hospital.latitude or 0.0,
                "hospital_longitude": hospital.longitude or 0.0,
                # For tracking speed
                "created_at": alert.created_at.isoformat() if alert.created_at else None
            })

        logger.info(f"[HospitalCases] Returning {len(response)} cases")
        return jsonify(response), 200
    
    except Exception as e:
        logger.error(f"[HospitalCases] Error: {str(e)}")
        traceback.print_exc()
        return jsonify(error=str(e)), 500
