from flask import Blueprint, jsonify, request
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

@ambulance_bp.route("/location", methods=["POST"])
@jwt_required()
def update_ambulance_location():
    """Update current ambulance location"""
    try:
        uid = int(get_jwt_identity())
        user = User.query.get(uid)
        
        if not user:
            return jsonify(msg="User not found"), 404
        
        # Get hospital associated with this user (ambulance drivers)
        hospital = Hospital.query.filter_by(user_id=uid).first()
        
        if not hospital:
            return jsonify(msg="Hospital not found for this user"), 404
        
        data = request.get_json()
        latitude = data.get("latitude")
        longitude = data.get("longitude")
        
        if latitude is None or longitude is None:
            return jsonify(error="latitude and longitude are required"), 400
        
        # Get the most recent active alert for this hospital
        alert = AmbulanceAlert.query.filter(
            AmbulanceAlert.hospital_id == hospital.id,
            AmbulanceAlert.status != 'delivered'
        ).order_by(AmbulanceAlert.created_at.desc()).first()
        
        if not alert:
            # No active alert for this hospital: return 200 so clients can continue sending location
            return jsonify({
                "message": "no_active_alert",
                "alert_id": None,
                "ambulance_latitude": None,
                "ambulance_longitude": None
            }), 200
        
        # Update ambulance location
        alert.ambulance_latitude = latitude
        alert.ambulance_longitude = longitude
        db.session.commit()
        
        print(f"[UpdateAmbulanceLocation] Alert {alert.id}: lat={latitude}, lon={longitude}")
        
        return jsonify({
            "alert_id": alert.id,
            "ambulance_latitude": alert.ambulance_latitude,
            "ambulance_longitude": alert.ambulance_longitude
        }), 200
    
    except Exception as e:
        print(f"[UpdateAmbulanceLocation Error] {str(e)}")
        return jsonify(error=str(e)), 500


@ambulance_bp.route("/location", methods=["OPTIONS"])
def update_ambulance_location_options():
    """Respond to CORS preflight for ambulance location updates"""
    # Flask-CORS will add the appropriate headers; just return OK so preflight succeeds
    return ('', 200)

@ambulance_bp.route("/location/<int:alert_id>", methods=["GET"])
@jwt_required()
def get_ambulance_location(alert_id):
    """Get ambulance location for a specific alert"""
    try:
        alert = AmbulanceAlert.query.get(alert_id)
        
        if not alert:
            return jsonify(msg="Alert not found"), 404
        
        return jsonify({
            "alert_id": alert.id,
            "ambulance_latitude": alert.ambulance_latitude,
            "ambulance_longitude": alert.ambulance_longitude,
            "status": alert.status
        }), 200
    
    except Exception as e:
        print(f"[GetAmbulanceLocation Error] {str(e)}")
        return jsonify(error=str(e)), 500
