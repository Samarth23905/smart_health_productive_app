from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Citizen, Hospital, AmbulanceAlert, Severity, Appointment, db
from utils import haversine, estimate_eta
from datetime import datetime

hospitals_bp = Blueprint("hospitals", __name__)

@hospitals_bp.route("/get-hospitals", methods=["GET"])
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