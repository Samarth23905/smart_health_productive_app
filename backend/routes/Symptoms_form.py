from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Citizen, Severity, db
from datetime import datetime
import logging
import traceback
from ml.ml_risk_model import build_features, predict_risk_percentage
from logic.logic_based import generate_precautions, determine_required_resources

symptoms_form_bp = Blueprint("symptoms_form", __name__)
logger = logging.getLogger(__name__)


def _get_risk_level(risk_percentage: int) -> str:
    """Map risk percentage to risk level"""
    if risk_percentage < 30:
        return "low"
    elif risk_percentage < 60:
        return "medium"
    elif risk_percentage < 85:
        return "high"
    else:
        return "critical"


@symptoms_form_bp.route("/submit", methods=["POST"])
@jwt_required()
def submit_symptoms():
    """
    Submit symptoms with details (duration and severity)
    Expected JSON:
    {
        "symptoms": "Chest Pain (3 days, severe) | Fever (1 days, mild)"
    }
    """
    try:
        # ============================
        # AUTH & BASIC VALIDATION
        # ============================
        current_user_id = int(get_jwt_identity())
        logger.info(f"[SubmitSymptoms] User ID: {current_user_id}")

        citizen = Citizen.query.filter_by(user_id=current_user_id).first()
        if not citizen:
            return jsonify({"error": "Citizen record not found"}), 404

        data = request.get_json()
        symptoms_text = data.get("symptoms", "").strip()

        if not symptoms_text:
            return jsonify({"error": "Symptoms cannot be empty"}), 400

        # ============================
        # PARSE SYMPTOMS
        # ============================
        symptoms_list = []
        symptom_details_dict = {}

        for item in symptoms_text.split(" | "):
            item = item.strip()
            if not item:
                continue

            parts = item.split("(")
            symptom_name = parts[0].strip()
            if not symptom_name:
                continue

            symptoms_list.append(symptom_name)

            try:
                if len(parts) > 1:
                    details = parts[1].replace(")", "").split(",")
                    days = int(details[0].strip().split()[0])
                    severity_level = details[1].strip() if len(details) > 1 else "mild"
                else:
                    days = 1
                    severity_level = "mild"
            except Exception:
                days = 1
                severity_level = "mild"

            symptom_details_dict[symptom_name] = {
                "days": days,
                "severity": severity_level
            }

        if not symptoms_list:
            return jsonify({"error": "No valid symptoms provided"}), 400

        # ============================
        # ALWAYS CREATE A NEW RECORD
        # ============================
        severity = Severity(citizen_id=citizen.id)

        severity.set_symptoms(symptoms_list)
        severity.set_symptom_details(symptom_details_dict)

        # 🔹 ML RISK PREDICTION
        features = build_features(symptom_details_dict)
        risk_percentage = predict_risk_percentage(features)

        severity.risk_percentage = risk_percentage
        severity.report_generated = True

        db.session.add(severity)
        db.session.commit()

        logger.info(f"[SubmitSymptoms] Created severity {severity.id}")

        # Generate health report
        precautions = generate_precautions(symptom_details_dict, risk_percentage)
        resources = determine_required_resources(symptom_details_dict, risk_percentage)

        health_report = {
            "current_symptoms": severity.get_symptoms(),
            "precautions": precautions,
            "required_hospital_resources": resources,
            "risk_level": _get_risk_level(risk_percentage),
            "risk_percentage": risk_percentage
        }

        return jsonify({
            "success": True,
            "message": "Symptoms submitted successfully",
            "severity_id": severity.id,
            "risk_percentage": risk_percentage,
            "health_report": health_report,
            "max_severity": severity.max_severity,
            "total_days": severity.total_days_symptomatic,
            "symptom_details": symptom_details_dict
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500