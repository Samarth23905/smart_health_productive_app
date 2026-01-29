from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Citizen, Hospital, AmbulanceAlert

hospital_bp = Blueprint("hospital", __name__)

@hospital_bp.route("/cases", methods=["GET"])
@jwt_required()
def hospital_cases():
    uid = int(get_jwt_identity())  # Parse string to int
    user = User.query.get(uid)
    
    if not user or user.role != "hospital":
        return jsonify(msg="Unauthorized"), 403

    # Get hospital record
    hospital = Hospital.query.filter_by(user_id=uid).first()

    if not hospital:
        return jsonify([])

    # Fetch ambulance alerts for this hospital (excluding delivered/completed)
    alerts = AmbulanceAlert.query.filter_by(
        hospital_id=hospital.id
    ).filter(AmbulanceAlert.status != 'delivered').order_by(AmbulanceAlert.created_at.desc()).all()

    response = []

    for alert in alerts:
        citizen = Citizen.query.get(alert.citizen_id)
        citizen_user = User.query.get(citizen.user_id)

        response.append({
            "name": citizen_user.name,
            "phone": citizen.phone,
            "sex": citizen.sex,
            # Symptoms & severity can come from severity table later
            "symptoms": "Reported via severity form",
            "severity": "Auto / User reported",
            "eta": alert.eta_minutes,
            "status": alert.status
        })

    return jsonify(response)
