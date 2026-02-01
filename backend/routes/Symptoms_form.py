from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import Citizen, Severity, db
from datetime import datetime
import logging
import traceback

symptoms_form_bp = Blueprint("symptoms_form", __name__)
logger = logging.getLogger(__name__)

@symptoms_form_bp.route("/submit", methods=["POST"])
@jwt_required()
def submit_symptoms():
    """
    Submit symptoms with details (duration and severity)
    Expected JSON format:
    {
        "symptoms": "Symptom1 (2 days, mild) | Symptom2 (3 days, moderate) | ..."
    }
    """
    try:
        current_user_id = int(get_jwt_identity())
        logger.info(f"[SubmitSymptoms] User ID: {current_user_id}")
        
        # Get citizen record
        citizen = Citizen.query.filter_by(user_id=current_user_id).first()
        if not citizen:
            logger.error(f"[SubmitSymptoms] Citizen record not found for user {current_user_id}")
            return jsonify({"error": "Citizen record not found"}), 404
        
        data = request.get_json()
        symptoms_text = data.get('symptoms', '')
        logger.info(f"[SubmitSymptoms] Received symptoms text: {symptoms_text[:100]}...")
        
        if not symptoms_text:
            logger.warning(f"[SubmitSymptoms] Empty symptoms for user {current_user_id}")
            return jsonify({"error": "Symptoms cannot be empty"}), 400
        
        # Parse symptoms string to extract just the symptom names
        # Format: "Symptom1 (2 days, mild) | Symptom2 (3 days, moderate)"
        symptoms_list = []
        for item in symptoms_text.split(" | "):
            # Extract symptom name (everything before the first parenthesis)
            symptom_name = item.split("(")[0].strip()
            if symptom_name:
                symptoms_list.append(symptom_name)
        
        logger.info(f"[SubmitSymptoms] Parsed symptoms: {symptoms_list}")
        
        if not symptoms_list:
            logger.warning(f"[SubmitSymptoms] No valid symptoms after parsing")
            return jsonify({"error": "No valid symptoms provided"}), 400
        
        # Check if citizen already has a severity record today
        today = datetime.utcnow().date()
        existing_severity = Severity.query.filter(
            Severity.citizen_id == citizen.id,
            db.func.date(Severity.created_at) == today
        ).first()
        
        if existing_severity:
            # Update existing record with new symptoms (merge with existing)
            existing_symptoms = existing_severity.get_symptoms_set()
            all_symptoms = list(existing_symptoms.union(set(symptoms_list)))
            existing_severity.set_symptoms(all_symptoms)
            existing_severity.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                "success": True,
                "message": "Symptoms updated successfully",
                "severity_id": existing_severity.id,
                "symptoms_count": len(all_symptoms),
                "symptoms": all_symptoms
            }), 200
        else:
            # Create new severity record
            severity = Severity(
                citizen_id=citizen.id,
                severity_level="low"  # Default level
            )
            severity.set_symptoms(symptoms_list)
            
            db.session.add(severity)
            db.session.commit()
            
            return jsonify({
                "success": True,
                "message": "Symptoms submitted successfully",
                "severity_id": severity.id,
                "symptoms_count": len(symptoms_list),
                "symptoms": symptoms_list
            }), 201
        
    except Exception as e:
        logger.error(f"[SubmitSymptoms] Error: {str(e)}")
        traceback.print_exc()
        db.session.rollback()
        return jsonify({"error": str(e), "type": type(e).__name__}), 500


@symptoms_form_bp.route("/get/<int:citizen_id>", methods=["GET"])
@jwt_required()
def get_citizen_symptoms(citizen_id):
    """Get all symptoms for a citizen"""
    try:
        severity_records = Severity.query.filter_by(citizen_id=citizen_id).all()
        
        if not severity_records:
            return jsonify({"symptoms": []}), 200
        
        response = []
        for record in severity_records:
            response.append({
                "id": record.id,
                "symptoms": record.get_symptoms(),
                "severity_level": record.severity_level,
                "created_at": record.created_at.isoformat(),
                "updated_at": record.updated_at.isoformat()
            })
        
        return jsonify({"symptoms": response}), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@symptoms_form_bp.route("/<int:severity_id>", methods=["GET"])
@jwt_required()
def get_severity_details(severity_id):
    """Get details of a specific severity record"""
    try:
        severity = Severity.query.get(severity_id)
        
        if not severity:
            return jsonify({"error": "Severity record not found"}), 404
        
        return jsonify({
            "id": severity.id,
            "citizen_id": severity.citizen_id,
            "symptoms": severity.get_symptoms(),
            "symptoms_set": list(severity.get_symptoms_set()),
            "severity_level": severity.severity_level,
            "created_at": severity.created_at.isoformat(),
            "updated_at": severity.updated_at.isoformat()
        }), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500