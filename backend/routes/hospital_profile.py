from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Hospital
from datetime import datetime

hospital_profile_bp = Blueprint("hospital_profile", __name__)

@hospital_profile_bp.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    """Get hospital profile information"""
    uid = int(get_jwt_identity())  # Parse string to int
    user = User.query.get(uid)
    hospital = Hospital.query.filter_by(user_id=uid).first()
    
    if not user or not hospital:
        return jsonify(error="User or hospital not found"), 404
    
    return jsonify({
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "phone": hospital.phone,
        "latitude": hospital.latitude,
        "longitude": hospital.longitude,
        "total_beds": hospital.total_beds,
        "icu_beds": hospital.icu_beds,
        "oxygen_available": hospital.oxygen_available,
        "profile_pic": hospital.profile_pic,

        "general_total": hospital.general_total,
        "general_available": hospital.general_available,
        "semi_total": hospital.semi_total,
        "semi_available": hospital.semi_available,
        "private_total": hospital.private_total,
        "private_available": hospital.private_available,
        "isolation_total": hospital.isolation_total,
        "isolation_available": hospital.isolation_available,

        "micu_total": hospital.micu_total,
        "micu_available": hospital.micu_available,
        "micu_ventilators": hospital.micu_ventilators,
        "micu_monitors": hospital.micu_monitors,
        "micu_oxygen": hospital.micu_oxygen,
        "sicu_total": hospital.sicu_total,
        "sicu_available": hospital.sicu_available,
        "sicu_ventilators": hospital.sicu_ventilators,
        "sicu_monitors": hospital.sicu_monitors,
        "sicu_oxygen": hospital.sicu_oxygen,
        "nicu_total": hospital.nicu_total,
        "nicu_available": hospital.nicu_available,
        "nicu_ventilators": hospital.nicu_ventilators,
        "nicu_monitors": hospital.nicu_monitors,
        "nicu_oxygen": hospital.nicu_oxygen,
        "ccu_total": hospital.ccu_total,
        "ccu_available": hospital.ccu_available,
        "ccu_ventilators": hospital.ccu_ventilators,
        "ccu_monitors": hospital.ccu_monitors,
        "ccu_oxygen": hospital.ccu_oxygen,
        "picu_total": hospital.picu_total,
        "picu_available": hospital.picu_available,
        "picu_ventilators": hospital.picu_ventilators,
        "picu_monitors": hospital.picu_monitors,
        "picu_oxygen": hospital.picu_oxygen,

        "emergency_24x7": hospital.emergency_24x7,
        "ambulance_available": hospital.ambulance_available,
        "ambulance_count": hospital.ambulance_count,
        "defibrillator": hospital.defibrillator,
        "central_oxygen": hospital.central_oxygen,

        "lab": hospital.lab,
        "xray": hospital.xray,
        "ecg": hospital.ecg,
        "ultrasound": hospital.ultrasound,
        "ct_scan": hospital.ct_scan,
        "mri": hospital.mri,

        "in_house_pharmacy": hospital.in_house_pharmacy,
        "pharmacy_24x7": hospital.pharmacy_24x7,
        "oxygen_cylinders": hospital.oxygen_cylinders,
        "essential_drugs": hospital.essential_drugs,

        "doctors_count": hospital.doctors_count,
        "nurses_count": hospital.nurses_count,
        "icu_trained_staff": hospital.icu_trained_staff,
        "anesthetist_available": hospital.anesthetist_available,

        "blood_bank": hospital.blood_bank,
        "dialysis_unit": hospital.dialysis_unit,
        "cssd": hospital.cssd,
        "mortuary": hospital.mortuary,
        "created_at": hospital.created_at.isoformat() if hospital.created_at else None,
        "updated_at": hospital.updated_at.isoformat() if hospital.updated_at else None
    }), 200

@hospital_profile_bp.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    """Update hospital profile information"""
    uid = int(get_jwt_identity())  # Parse string to int
    user = User.query.get(uid)
    hospital = Hospital.query.filter_by(user_id=uid).first()
    
    if not user or not hospital:
        return jsonify(error="User or hospital not found"), 404
    
    data = request.get_json()
    
    # Update user fields
    if "name" in data:
        user.name = data["name"]
    if "email" in data:
        # Check if email already exists
        existing = User.query.filter_by(email=data["email"]).first()
        if existing and existing.id != uid:
            return jsonify(error="Email already in use"), 409
        user.email = data["email"]
    
    # Update hospital fields
    if "phone" in data:
        hospital.phone = data["phone"]
    if "latitude" in data:
        hospital.latitude = data["latitude"]
    if "longitude" in data:
        hospital.longitude = data["longitude"]
    if "total_beds" in data:
        hospital.total_beds = data["total_beds"]
    if "icu_beds" in data:
        hospital.icu_beds = data["icu_beds"]
    if "oxygen_available" in data:
        hospital.oxygen_available = data["oxygen_available"]
    # Ward resources
    if "general_total" in data:
        hospital.general_total = data["general_total"]
    if "general_available" in data:
        hospital.general_available = data["general_available"]
    if "semi_total" in data:
        hospital.semi_total = data["semi_total"]
    if "semi_available" in data:
        hospital.semi_available = data["semi_available"]
    if "private_total" in data:
        hospital.private_total = data["private_total"]
    if "private_available" in data:
        hospital.private_available = data["private_available"]
    if "isolation_total" in data:
        hospital.isolation_total = data["isolation_total"]
    if "isolation_available" in data:
        hospital.isolation_available = data["isolation_available"]

    # ICU resources
    for prefix in ['micu','sicu','nicu','ccu','picu']:
        if f"{prefix}_total" in data:
            setattr(hospital, f"{prefix}_total", data[f"{prefix}_total"])
        if f"{prefix}_available" in data:
            setattr(hospital, f"{prefix}_available", data[f"{prefix}_available"])
        if f"{prefix}_ventilators" in data:
            setattr(hospital, f"{prefix}_ventilators", data[f"{prefix}_ventilators"])
        if f"{prefix}_monitors" in data:
            setattr(hospital, f"{prefix}_monitors", data[f"{prefix}_monitors"])
        if f"{prefix}_oxygen" in data:
            setattr(hospital, f"{prefix}_oxygen", data[f"{prefix}_oxygen"])

    # Emergency
    if "emergency_24x7" in data:
        hospital.emergency_24x7 = data["emergency_24x7"]
    if "ambulance_available" in data:
        hospital.ambulance_available = data["ambulance_available"]
    if "ambulance_count" in data:
        hospital.ambulance_count = data["ambulance_count"]
    if "defibrillator" in data:
        hospital.defibrillator = data["defibrillator"]
    if "central_oxygen" in data:
        hospital.central_oxygen = data["central_oxygen"]

    # Diagnostics
    for f in ['lab','xray','ecg','ultrasound','ct_scan','mri']:
        if f in data:
            setattr(hospital, f, data[f])

    # Pharmacy & supplies
    if "in_house_pharmacy" in data:
        hospital.in_house_pharmacy = data["in_house_pharmacy"]
    if "pharmacy_24x7" in data:
        hospital.pharmacy_24x7 = data["pharmacy_24x7"]
    if "oxygen_cylinders" in data:
        hospital.oxygen_cylinders = data["oxygen_cylinders"]
    if "essential_drugs" in data:
        hospital.essential_drugs = data["essential_drugs"]

    # HR
    if "doctors_count" in data:
        hospital.doctors_count = data["doctors_count"]
    if "nurses_count" in data:
        hospital.nurses_count = data["nurses_count"]
    if "icu_trained_staff" in data:
        hospital.icu_trained_staff = data["icu_trained_staff"]
    if "anesthetist_available" in data:
        hospital.anesthetist_available = data["anesthetist_available"]

    # Support
    for f in ['blood_bank','dialysis_unit','cssd','mortuary']:
        if f in data:
            setattr(hospital, f, data[f])
    if "profile_pic" in data:
        hospital.profile_pic = data["profile_pic"]  # base64 encoded image
    
    hospital.updated_at = datetime.utcnow()
    
    db.session.commit()
    
    return jsonify({
        "msg": "Profile updated successfully",
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "phone": hospital.phone,
        "latitude": hospital.latitude,
        "longitude": hospital.longitude,
        "total_beds": hospital.total_beds,
        "icu_beds": hospital.icu_beds,
        "oxygen_available": hospital.oxygen_available,
        "profile_pic": hospital.profile_pic
    }), 200

@hospital_profile_bp.route("/profile/picture", methods=["POST"])
@jwt_required()
def upload_profile_picture():
    """Upload profile picture as base64"""
    uid = int(get_jwt_identity())  # Parse string to int
    hospital = Hospital.query.filter_by(user_id=uid).first()
    
    if not hospital:
        return jsonify(error="Hospital not found"), 404
    
    data = request.get_json()
    
    if not data or not data.get("image"):
        return jsonify(error="Missing image data"), 400
    
    hospital.profile_pic = data["image"]  # Should be base64 encoded image
    hospital.updated_at = datetime.utcnow()
    db.session.commit()
    
    return jsonify({
        "msg": "Profile picture updated",
        "profile_pic": hospital.profile_pic
    }), 200

@hospital_profile_bp.route("/profile/picture", methods=["GET"])
@jwt_required()
def get_profile_picture():
    """Get hospital profile picture"""
    uid = int(get_jwt_identity())  # Parse string to int
    hospital = Hospital.query.filter_by(user_id=uid).first()
    
    if not hospital:
        return jsonify(error="Hospital not found"), 404
    
    return jsonify({
        "profile_pic": hospital.profile_pic
    }), 200
