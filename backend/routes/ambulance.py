from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Hospital, AmbulanceAlert
from datetime import datetime
import math

ambulance_bp = Blueprint("ambulance", __name__)

def _haversine_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two points using Haversine formula.
    Returns distance in kilometers.
    """
    if not all([lat1, lon1, lat2, lon2]):
        return 0

    try:
        # Convert to radians
        p = math.pi / 180.0
        lat1_rad = lat1 * p
        lon1_rad = lon1 * p
        lat2_rad = lat2 * p
        lon2_rad = lon2 * p

        # Haversine formula
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        a = (math.sin(dlat / 2) ** 2) + math.cos(lat1_rad) * math.cos(lat2_rad) * (math.sin(dlon / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

        # Earth's radius in km
        earth_radius_km = 6371.0
        distance = earth_radius_km * c

        return distance
    except Exception as e:
        print(f"[Haversine Error] {str(e)}")
        return 0

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
    """Update current ambulance location and calculate real-time speed using Haversine formula"""
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
                "ambulance_longitude": None,
                "ambulance_speed_kmh": 0
            }), 200

        # Calculate speed using Haversine formula if we have previous location
        calculated_speed_kmh = 0
        if (alert.prev_ambulance_latitude is not None and
            alert.prev_ambulance_longitude is not None and
            alert.last_location_update is not None):

            # Calculate distance using Haversine
            distance_km = _haversine_distance(
                alert.prev_ambulance_latitude,
                alert.prev_ambulance_longitude,
                latitude,
                longitude
            )

            # Calculate time elapsed since last update
            time_diff_seconds = (datetime.utcnow() - alert.last_location_update).total_seconds()

            if time_diff_seconds > 1:  # At least 1 second elapsed
                # Speed = distance / time
                time_diff_hours = time_diff_seconds / 3600.0
                calculated_speed_kmh = distance_km / time_diff_hours

                # Apply exponential moving average (70% old + 30% new) to smooth GPS noise
                if alert.ambulance_speed_kmh > 0:
                    calculated_speed_kmh = (alert.ambulance_speed_kmh * 0.7) + (calculated_speed_kmh * 0.3)

                print(f"[UpdateAmbulanceLocation] Alert {alert.id}: Distance={distance_km:.2f}km, Time={time_diff_seconds:.0f}s, Speed={calculated_speed_kmh:.2f}km/h")

        # Update ambulance location and speed
        alert.prev_ambulance_latitude = alert.ambulance_latitude
        alert.prev_ambulance_longitude = alert.ambulance_longitude
        alert.last_location_update = datetime.utcnow()
        alert.ambulance_latitude = latitude
        alert.ambulance_longitude = longitude
        alert.ambulance_speed_kmh = max(0, calculated_speed_kmh)  # Ensure non-negative

        db.session.commit()

        print(f"[UpdateAmbulanceLocation] Alert {alert.id}: lat={latitude}, lon={longitude}, speed={alert.ambulance_speed_kmh:.2f}km/h")

        return jsonify({
            "alert_id": alert.id,
            "ambulance_latitude": alert.ambulance_latitude,
            "ambulance_longitude": alert.ambulance_longitude,
            "ambulance_speed_kmh": round(alert.ambulance_speed_kmh, 2)
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
    """Get ambulance location and real-time speed for a specific alert"""
    try:
        alert = AmbulanceAlert.query.get(alert_id)

        if not alert:
            return jsonify(msg="Alert not found"), 404

        return jsonify({
            "alert_id": alert.id,
            "ambulance_latitude": alert.ambulance_latitude,
            "ambulance_longitude": alert.ambulance_longitude,
            "ambulance_speed_kmh": round(alert.ambulance_speed_kmh, 2) if alert.ambulance_speed_kmh else 0,
            "status": alert.status
        }), 200

    except Exception as e:
        print(f"[GetAmbulanceLocation Error] {str(e)}")
        return jsonify(error=str(e)), 500
