from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Hospital, AmbulanceAlert

ambulance_bp = Blueprint("ambulance", __name__)

@ambulance_bp.route("/dashboard")
@jwt_required()
def dashboard():
    """Get ambulance alerts for the hospital the user belongs to"""
    try:
        uid = int(get_jwt_identity())
        user = User.query.get(uid)
        
        if not user:
            return jsonify(msg="User not found"), 404
        
        # Get hospital associated with this user (ambulance drivers login as hospital)
        hospital = Hospital.query.filter_by(user_id=uid).first()
        
        if not hospital:
            return jsonify(msg="Hospital not found for this user"), 404
        
        # Get only non-delivered alerts for this hospital
        alerts = AmbulanceAlert.query.filter(
            AmbulanceAlert.hospital_id == hospital.id,
            AmbulanceAlert.status != 'delivered'
        ).all()
        
        print(f"[AmbulanceDashboard] User {uid} - Hospital {hospital.id}")
        print(f"[AmbulanceDashboard] Non-delivered alerts for this hospital: {len(alerts)}")
        for alert in alerts:
            print(f"  - Alert {alert.id}: status={alert.status}, citizen_id={alert.citizen_id}")
        
        return jsonify([
            {
                "alert_id": a.id,
                "citizen_id": a.citizen_id,
                "eta": a.eta_minutes,
                "status": a.status
            } for a in alerts
        ]), 200
    
    except Exception as e:
        print(f"[AmbulanceDashboard Error] {str(e)}")
        return jsonify(error=str(e)), 500
