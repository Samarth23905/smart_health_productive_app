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
