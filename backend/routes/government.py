from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Citizen, Hospital, Severity, AmbulanceAlert
from datetime import datetime, timedelta
from sqlalchemy import func, or_
import statistics
import math

government_bp = Blueprint("government", __name__)

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

def _calculate_eta_from_haversine(ambulance_lat, ambulance_lon, hospital_lat, hospital_lon, ambulance_speed_kmh=45.0):
    """
    Calculate ETA in minutes using Haversine distance and given speed.
    Default ambulance speed: 45 km/h
    """
    if ambulance_speed_kmh <= 0:
        ambulance_speed_kmh = 45.0

    distance_km = _haversine_distance(ambulance_lat, ambulance_lon, hospital_lat, hospital_lon)

    # ETA in minutes: (distance / speed) * 60
    eta_minutes = (distance_km / ambulance_speed_kmh) * 60
    return max(0, math.ceil(eta_minutes))

@government_bp.route("/analytics", methods=["GET"])
@jwt_required()
def get_analytics():
    try:
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        if not user or user.role != "government":
            return jsonify({"error": "Unauthorized"}), 403
        
        # ============================================
        # SECTION 1: UNIFIED DATA AGGREGATION
        # ============================================
        total_alerts = db.session.query(func.count(AmbulanceAlert.id)).scalar() or 0
        total_citizens = db.session.query(func.count(Citizen.id)).scalar() or 0
        active_hospitals = db.session.query(func.count(Hospital.id)).scalar() or 0

        # Count ambulances by summing ambulance_count from all hospitals
        ambulance_count = db.session.query(func.sum(Hospital.ambulance_count)).scalar() or 0
        
        # ============================================
        # SECTION 2: SEVERITY DISTRIBUTION
        # ============================================
        severity_low = db.session.query(func.count(Severity.id)).filter(
            Severity.severity_level == "low"
        ).scalar() or 0
        severity_medium = db.session.query(func.count(Severity.id)).filter(
            Severity.severity_level == "medium"
        ).scalar() or 0
        severity_high = db.session.query(func.count(Severity.id)).filter(
            Severity.severity_level == "high"
        ).scalar() or 0
        
        severity_distribution = {
            "low": severity_low,
            "medium": severity_medium,
            "high": severity_high,
        }
        
        # ============================================
        # SECTION 3: ALERT COMPLETION METRICS
        # ============================================
        # Count alerts that are completed or delivered (some parts of the app use 'delivered')
        completed_alerts = db.session.query(func.count(AmbulanceAlert.id)).filter(
            AmbulanceAlert.status.in_(["completed", "delivered"])
        ).scalar() or 0
        
        # ============================================
        # SECTION 4: ETA STATISTICS (USING HAVERSINE)
        # ============================================
        # Get all active alerts with location data
        active_alerts = AmbulanceAlert.query.filter(
            AmbulanceAlert.status.in_(["dispatched", "on_the_way", "arrived"])
        ).all()

        eta_list = []

        # Calculate ETA for active alerts using Haversine formula
        for alert in active_alerts:
            try:
                # Get ambulance location
                ambulance_lat = alert.ambulance_latitude
                ambulance_lon = alert.ambulance_longitude

                # Get hospital location from hospital_id
                hospital = Hospital.query.get(alert.hospital_id)
                if not hospital or not hospital.latitude or not hospital.longitude:
                    continue

                hospital_lat = hospital.latitude
                hospital_lon = hospital.longitude

                # Use real-time ambulance speed if available, fallback to 45 km/h
                ambulance_speed = alert.ambulance_speed_kmh if alert.ambulance_speed_kmh > 0 else 45.0

                # Calculate ETA using Haversine formula with real-time speed
                calculated_eta = _calculate_eta_from_haversine(
                    ambulance_lat, ambulance_lon,
                    hospital_lat, hospital_lon,
                    ambulance_speed_kmh=ambulance_speed
                )

                if calculated_eta > 0:
                    eta_list.append(calculated_eta)
                    print(f"[Government Analytics] Alert {alert.id}: Distance ETA calculated, Speed={ambulance_speed:.2f}km/h, ETA={calculated_eta}min")
            except Exception as e:
                print(f"[Government Analytics] Error calculating ETA for alert {alert.id}: {str(e)}")
                continue

        # Fallback: if no active alerts, use historical data
        if not eta_list:
            eta_values = db.session.query(AmbulanceAlert.eta_minutes).filter(
                AmbulanceAlert.eta_minutes.isnot(None)
            ).all()
            eta_list = sorted([e[0] for e in eta_values if e[0] is not None])

        eta_list = sorted(eta_list)

        print(f"[Government Analytics] ETA list size: {len(eta_list)}, Active alerts: {len(active_alerts)}, Calculated using Haversine: {len(active_alerts) > 0}")

        # Calculate statistics
        eta_statistics = {
            "mean": round(sum(eta_list) / len(eta_list), 2) if eta_list else 0,
            "median": round(_get_percentile(eta_list, 50), 2) if eta_list else 0,
            "min": round(min(eta_list), 2) if eta_list else 0,
            "max": round(max(eta_list), 2) if eta_list else 0,
            "p50": round(_get_percentile(eta_list, 50), 2) if eta_list else 0,
            "p95": round(_get_percentile(eta_list, 95), 2) if eta_list else 0,
            "p99": round(_get_percentile(eta_list, 99), 2) if eta_list else 0,
            "std_dev": round(_calculate_std_dev(eta_list), 2) if eta_list else 0,
        }
        
        # ============================================
        # SECTION 5: INFRASTRUCTURE STATUS
        # ============================================
        hospitals = Hospital.query.all()
        total_beds = sum(h.total_beds or 0 for h in hospitals)
        icu_beds = sum(h.icu_beds or 0 for h in hospitals)

        print(f"[Government Analytics] Hospitals count: {len(hospitals)}, Total beds: {total_beds}, ICU beds: {icu_beds}")
        if hospitals:
            print(f"[Government Analytics] Hospital bed details: {[(h.name if hasattr(h, 'name') else h.id, h.total_beds, h.icu_beds) for h in hospitals[:3]]}")

        oxygen_hospitals = db.session.query(func.count(Hospital.id)).filter(
            Hospital.oxygen_available == True
        ).scalar() or 0

        # ============================================
        # SECTION 6b: DIGITAL ADOPTION / REGISTERED CITIZENS
        # ============================================
        # registered_citizens: citizens whose linked User has phone or email
        registered_citizens = db.session.query(func.count(Citizen.id)).join(
            User, User.id == Citizen.user_id
        ).filter(
            or_(User.phone.isnot(None), User.email.isnot(None))
        ).scalar() or 0

        digital_adoption = 0
        try:
            if total_citizens and total_citizens > 0:
                digital_adoption = round((registered_citizens / total_citizens) * 100, 1)
        except Exception:
            digital_adoption = 0
        
        # ============================================
        # SECTION 6: ENGAGEMENT METRICS
        # ============================================
        avg_eta = eta_statistics["mean"]
        
        # ============================================
        # SECTION 7: ALERT STATUS DISTRIBUTION
        # ============================================
        status_counts = db.session.query(
            AmbulanceAlert.status,
            func.count(AmbulanceAlert.id).label("count")
        ).group_by(AmbulanceAlert.status).all()
        
        status_distribution = {status: count for status, count in status_counts}
        
        print(f"[Government Analytics] ✓ Haversine-based ETA - Active alerts: {len(active_alerts)}")
        print(f"[Government Analytics] ETA Statistics (Haversine-calculated) - Mean: {eta_statistics['mean']}min, Median: {eta_statistics['median']}min, Std Dev: {eta_statistics['std_dev']}, P95: {eta_statistics['p95']}min")

        return jsonify({
            # ETA Analysis & Estimation (using real-time speed)
            "eta_statistics": eta_statistics,
            "eta_calculation_method": "haversine_distance_with_realtime_speed" if len(active_alerts) > 0 else "historical_data",
            "active_alerts_with_eta": len(eta_list),
            "average_eta": eta_statistics["mean"],
            "median_eta": eta_statistics["median"],
            "min_eta": eta_statistics["min"],
            "max_eta": eta_statistics["max"],
            "eta_percentiles": {
                "p50": eta_statistics["p50"],
                "p95": eta_statistics["p95"],
                "p99": eta_statistics["p99"]
            },
            "eta_std_deviation": eta_statistics["std_dev"],
            "total_active_alerts": len(active_alerts),
            "calculation_timestamp": datetime.utcnow().isoformat()
        }), 200
    
    except Exception as e:
        print(f"[Government Analytics Error] {str(e)}")
        return jsonify({"error": str(e)}), 500


def _calculate_std_dev(data):
    """Calculate standard deviation"""
    if not data or len(data) < 2:
        return 0
    
    mean = sum(data) / len(data)
    variance = sum((x - mean) ** 2 for x in data) / len(data)
    return variance ** 0.5


def _get_percentile(data, percentile):
    """Calculate percentile value"""
    if not data:
        return 0
    if percentile == 50:
        return statistics.median(data)
    
    index = int(len(data) * percentile / 100)
    return data[index] if index < len(data) else data[-1]