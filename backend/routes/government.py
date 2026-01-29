from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Citizen, Hospital, Severity, AmbulanceAlert
from datetime import datetime, timedelta
from sqlalchemy import func
import statistics

government_bp = Blueprint("government", __name__)

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
        ambulance_count = db.session.query(func.count(AmbulanceAlert.id)).filter(
            AmbulanceAlert.status.in_(["dispatched", "on_the_way", "arrived"])
        ).scalar() or 0
        
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
        completed_alerts = db.session.query(func.count(AmbulanceAlert.id)).filter(
            AmbulanceAlert.status == "completed"
        ).scalar() or 0
        
        # ============================================
        # SECTION 4: ETA STATISTICS
        # ============================================
        eta_values = db.session.query(AmbulanceAlert.eta_minutes).filter(
            AmbulanceAlert.eta_minutes.isnot(None)
        ).all()
        eta_list = sorted([e[0] for e in eta_values if e[0] is not None])
        
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
        oxygen_hospitals = db.session.query(func.count(Hospital.id)).filter(
            Hospital.oxygen_available == True
        ).scalar() or 0
        
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
        
        print(f"[Government Analytics] Total alerts: {total_alerts}, Citizens: {total_citizens}")
        
        return jsonify({
            # Section 1: Unified Data
            "total_alerts": total_alerts,
            "total_citizens": total_citizens,
            "active_hospitals": active_hospitals,
            "ambulance_count": ambulance_count,
            
            # Section 2: Severity
            "severity_distribution": severity_distribution,
            
            # Section 3: Completion
            "completed_alerts": completed_alerts,
            
            # Section 4: ETA Analytics
            "eta_statistics": eta_statistics,
            
            # Section 5: Infrastructure
            "total_beds": total_beds,
            "icu_beds": icu_beds,
            "oxygen_hospitals": oxygen_hospitals,
            
            # Section 6: Engagement
            "avg_eta": avg_eta,
            
            # Section 7: Status Distribution
            "status_distribution": status_distribution,
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