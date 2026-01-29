from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, Citizen
from datetime import datetime

citizen_profile_bp = Blueprint("citizen_profile", __name__)

@citizen_profile_bp.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    """Get citizen profile information"""
    uid = int(get_jwt_identity())  # Parse string to int
    user = User.query.get(uid)
    citizen = Citizen.query.filter_by(user_id=uid).first()
    
    if not user or not citizen:
        return jsonify(error="User or citizen not found"), 404
    
    return jsonify({
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "phone": citizen.phone,
        "sex": citizen.sex,
        "latitude": citizen.latitude,
        "longitude": citizen.longitude,
        "profile_pic": citizen.profile_pic,
        "created_at": citizen.created_at.isoformat() if citizen.created_at else None,
        "updated_at": citizen.updated_at.isoformat() if citizen.updated_at else None
    }), 200

@citizen_profile_bp.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    """Update citizen profile information"""
    uid = int(get_jwt_identity())  # Parse string to int
    user = User.query.get(uid)
    citizen = Citizen.query.filter_by(user_id=uid).first()
    
    if not user or not citizen:
        return jsonify(error="User or citizen not found"), 404
    
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
    
    # Update citizen fields
    if "phone" in data:
        citizen.phone = data["phone"]
    if "sex" in data:
        citizen.sex = data["sex"]
    if "latitude" in data:
        citizen.latitude = data["latitude"]
    if "longitude" in data:
        citizen.longitude = data["longitude"]
    if "profile_pic" in data:
        citizen.profile_pic = data["profile_pic"]  # base64 encoded image
    
    citizen.updated_at = datetime.utcnow()
    
    db.session.commit()
    
    return jsonify({
        "msg": "Profile updated successfully",
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "phone": citizen.phone,
        "sex": citizen.sex,
        "latitude": citizen.latitude,
        "longitude": citizen.longitude,
        "profile_pic": citizen.profile_pic
    }), 200

@citizen_profile_bp.route("/profile/picture", methods=["POST"])
@jwt_required()
def upload_profile_picture():
    """Upload profile picture as base64"""
    uid = int(get_jwt_identity())  # Parse string to int
    citizen = Citizen.query.filter_by(user_id=uid).first()
    
    if not citizen:
        return jsonify(error="Citizen not found"), 404
    
    data = request.get_json()
    
    if not data or not data.get("image"):
        return jsonify(error="Missing image data"), 400
    
    citizen.profile_pic = data["image"]  # Should be base64 encoded image
    citizen.updated_at = datetime.utcnow()
    db.session.commit()
    
    return jsonify({
        "msg": "Profile picture updated",
        "profile_pic": citizen.profile_pic
    }), 200

@citizen_profile_bp.route("/profile/picture", methods=["GET"])
@jwt_required()
def get_profile_picture():
    """Get citizen profile picture"""
    uid = int(get_jwt_identity())  # Parse string to int
    citizen = Citizen.query.filter_by(user_id=uid).first()
    
    if not citizen:
        return jsonify(error="Citizen not found"), 404
    
    return jsonify({
        "profile_pic": citizen.profile_pic
    }), 200
