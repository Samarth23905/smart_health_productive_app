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

        # Parse symptoms string to extract symptom names AND extract details (days, severity)
        # Format: "Symptom1 (2 days, mild) | Symptom2 (3 days, moderate)"
        symptoms_list = []
        symptom_details_dict = {}

        for item in symptoms_text.split(" | "):
            item = item.strip()
            if not item:
                continue

            # Extract symptom name and details
            # Format: "Chest Pain (3 days, severe)"
            parts = item.split("(")
            symptom_name = parts[0].strip()

            if symptom_name:
                symptoms_list.append(symptom_name)

                # Extract days and severity from details
                if len(parts) > 1:
                    details_text = parts[1].replace(")", "").strip()  # "3 days, severe"
                    details_split = details_text.split(",")

                    try:
                        # Extract days (e.g., "3 days" -> 3)
                        days_str = details_split[0].strip()  # "3 days"
                        days = int(days_str.split()[0])  # Extract number before "days"

                        # Extract severity (e.g., "severe")
                        severity = details_split[1].strip() if len(details_split) > 1 else "mild"

                        symptom_details_dict[symptom_name] = {
                            "days": days,
                            "severity": severity
                        }
                        logger.info(f"[SubmitSymptoms] Parsed: {symptom_name} - {days} days, {severity}")
                    except (ValueError, IndexError) as e:
                        logger.warning(f"[SubmitSymptoms] Could not parse details for {symptom_name}: {str(e)}")
                        symptom_details_dict[symptom_name] = {
                            "days": 1,
                            "severity": "mild"
                        }
                else:
                    # No details provided, use defaults
                    symptom_details_dict[symptom_name] = {
                        "days": 1,
                        "severity": "mild"
                    }

        logger.info(f"[SubmitSymptoms] Parsed symptoms: {symptoms_list}")
        logger.info(f"[SubmitSymptoms] Symptom details: {symptom_details_dict}")

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
            existing_details = existing_severity.get_symptom_details()

            # Merge symptom details
            merged_details = {**existing_details, **symptom_details_dict}
            all_symptoms = list(existing_symptoms.union(set(symptoms_list)))

            existing_severity.set_symptoms(all_symptoms)
            existing_severity.set_symptom_details(merged_details)
            existing_severity.updated_at = datetime.utcnow()
            db.session.commit()

            logger.info(f"[SubmitSymptoms] Updated severity record {existing_severity.id}")

            return jsonify({
                "success": True,
                "message": "Symptoms updated successfully",
                "severity_id": existing_severity.id,
                "symptoms_count": len(all_symptoms),
                "symptoms": all_symptoms,
                "max_severity": existing_severity.max_severity,
                "total_days": existing_severity.total_days_symptomatic,
                "symptom_details": merged_details
            }), 200
        else:
            # Create new severity record
            try:
                severity = Severity(
                    citizen_id=citizen.id
                )
                logger.info(f"[SubmitSymptoms] Created Severity object: {severity}")

                severity.set_symptoms(symptoms_list)
                logger.info(f"[SubmitSymptoms] Symptoms set to: {severity.symptoms}")

                severity.set_symptom_details(symptom_details_dict)
                logger.info(f"[SubmitSymptoms] Symptom details set: max_severity={severity.max_severity}, total_days={severity.total_days_symptomatic}")

                db.session.add(severity)
                logger.info(f"[SubmitSymptoms] Severity object added to session")

                db.session.commit()
                logger.info(f"[SubmitSymptoms] Database commit successful. Created severity record {severity.id}")

                return jsonify({
                    "success": True,
                    "message": "Symptoms submitted successfully",
                    "severity_id": severity.id,
                    "symptoms_count": len(symptoms_list),
                    "symptoms": symptoms_list,
                    "max_severity": severity.max_severity,
                    "total_days": severity.total_days_symptomatic,
                    "symptom_details": symptom_details_dict
                }), 201

            except Exception as inner_e:
                logger.error(f"[SubmitSymptoms] Error during database commit: {str(inner_e)}")
                logger.error(f"[SubmitSymptoms] Error type: {type(inner_e).__name__}")
                traceback.print_exc()
                db.session.rollback()
                raise

    except Exception as e:
        logger.error(f"[SubmitSymptoms] Error: {str(e)}")
        logger.error(f"[SubmitSymptoms] Error type: {type(e).__name__}")
        traceback.print_exc()
        db.session.rollback()
        return jsonify({"error": str(e), "type": type(e).__name__}), 500


@symptoms_form_bp.route("/get/<int:citizen_id>", methods=["GET"])
@jwt_required()
def get_citizen_symptoms(citizen_id):
    """Get all symptoms for a citizen with detailed information"""
    try:
        severity_records = Severity.query.filter_by(citizen_id=citizen_id).all()

        if not severity_records:
            return jsonify({"symptoms": []}), 200

        response = []
        for record in severity_records:
            response.append({
                "id": record.id,
                "symptoms": record.get_symptoms(),
                "symptom_details": record.get_symptom_details(),  # NEW: Detailed info
                "severity_level": record.severity_level,
                "max_severity": record.max_severity,  # NEW: Highest severity
                "total_days_symptomatic": record.total_days_symptomatic,  # NEW: Duration
                "created_at": record.created_at.isoformat(),
                "updated_at": record.updated_at.isoformat()
            })

        return jsonify({"symptoms": response}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@symptoms_form_bp.route("/<int:severity_id>", methods=["GET"])
@jwt_required()
def get_severity_details(severity_id):
    """Get details of a specific severity record with full symptom information"""
    try:
        severity = Severity.query.get(severity_id)

        if not severity:
            return jsonify({"error": "Severity record not found"}), 404

        return jsonify({
            "id": severity.id,
            "citizen_id": severity.citizen_id,
            "symptoms": severity.get_symptoms(),
            "symptoms_set": list(severity.get_symptoms_set()),
            "symptom_details": severity.get_symptom_details(),  # NEW: Full details with days/severity
            "severity_level": severity.severity_level,
            "max_severity": severity.max_severity,  # NEW: Highest severity
            "total_days_symptomatic": severity.total_days_symptomatic,  # NEW: Max symptom duration
            "created_at": severity.created_at.isoformat(),
            "updated_at": severity.updated_at.isoformat()
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500