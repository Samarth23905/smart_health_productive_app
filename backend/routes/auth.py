from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token, get_jwt_identity
from models import db, User, Citizen, Hospital
import logging
import traceback
import json

auth_bp = Blueprint("auth", __name__)
logger = logging.getLogger(__name__)

@auth_bp.route("/register", methods=["POST"])
def register():
    try:
        data = request.json
        
        # Validate required fields
        if not data or not data.get("role") or not data.get("name") or not data.get("password"):
            return jsonify(error="Missing required fields: role, name, password"), 400
        
        # Check if user with same email already exists
        if data.get("email") and User.query.filter_by(email=data.get("email")).first():
            return jsonify(error="Email already registered"), 409
        
        # Check if user with same name and role already exists
        if User.query.filter_by(name=data["name"], role=data["role"]).first():
            return jsonify(error="User with this name and role already exists"), 409
        
        user = User(
            role=data["role"],
            name=data["name"],
            email=data.get("email") or None,
            phone=data.get("phone"),
            profile_pic=data.get("profile_pic"),  # base64 encoded image
            password=generate_password_hash(data["password"])
        )
        db.session.add(user)
        db.session.flush()  # Get user.id without committing yet
        
        # Create role-specific profile
        if data["role"] == "citizen":
            lat = float(data.get("latitude", 0)) if data.get("latitude") else 0.0
            lng = float(data.get("longitude", 0)) if data.get("longitude") else 0.0
            print(f"[Register Citizen] Storing location: lat={lat}, lng={lng}")
            citizen = Citizen(
                user_id=user.id,
                phone=data.get("phone"),
                sex=data.get("sex"),
                latitude=lat,
                longitude=lng,
                profile_pic=data.get("profile_pic")
            )
            db.session.add(citizen)
        
        elif data["role"] == "hospital":
            lat = float(data.get("latitude", 0)) if data.get("latitude") else 0.0
            lng = float(data.get("longitude", 0)) if data.get("longitude") else 0.0
            print(f"[Register Hospital] Storing location: lat={lat}, lng={lng}")
            hospital = Hospital(
                user_id=user.id,
                phone=data.get("phone"),
                latitude=lat,
                longitude=lng,
                total_beds=data.get("total_beds", 0),
                icu_beds=data.get("icu_beds", 0),
                oxygen_available=data.get("oxygen_available", False),
                profile_pic=data.get("profile_pic")
            )
            db.session.add(hospital)
    
        
        db.session.commit()
        return jsonify(msg="Registered successfully", user_id=user.id), 201
    
    except Exception as e:
        db.session.rollback()
        traceback.print_exc()
        logger.error(f"Register error: {str(e)}", exc_info=True)
        return jsonify(error=str(e)), 500

@auth_bp.route("/login", methods=["POST"])
def login():
    try:
        data = request.json
        
        if not data or not data.get("credential") or not data.get("role") or not data.get("password"):
            # Support both old format (name field) and new format (credential field)
            if not data or not (data.get("name") or data.get("credential")) or not data.get("role") or not data.get("password"):
                return jsonify(error="Missing required fields: credential (email/phone/name), role, password"), 400
        
        role = data["role"]
        credential = data.get("credential") or data.get("name")  # Support both field names
        
        user = None
        
        if role == "citizen":
            # For citizens, try to find by email, phone, or name
            print(f"[Login] Citizen login attempt with credential: {credential}")
            
            # Check if credential is an email (contains @)
            if "@" in credential:
                user = User.query.filter_by(email=credential, role="citizen").first()
                print(f"[Login] Searched by email: {credential}")
            else:
                # Check if credential is a phone number (digits only or with common separators)
                phone_digits = ''.join(c for c in credential if c.isdigit())
                if len(phone_digits) >= 10 and phone_digits == credential.replace("-", "").replace(" ", ""):
                    # Search by phone in both User and Citizen tables
                    user = User.query.filter_by(phone=credential, role="citizen").first()
                    if not user:
                        # Also check in Citizen table via phone
                        citizen_obj = Citizen.query.filter_by(phone=credential).first()
                        if citizen_obj:
                            user = User.query.get(citizen_obj.user_id)
                    print(f"[Login] Searched by phone: {credential}")
                else:
                    # Search by name
                    user = User.query.filter_by(name=credential, role="citizen").first()
                    print(f"[Login] Searched by name: {credential}")
        
        elif role == "ambulance":
            # For ambulance role, authenticate using hospital credentials
            user = User.query.filter_by(name=credential, role="hospital").first()
            print(f"[Login] Ambulance login (hospital role): {credential}")
        
        else:
            # For other roles (hospital, government), search by name
            user = User.query.filter_by(name=credential, role=role).first()
            print(f"[Login] {role} login: {credential}")
        
        if not user:
            print(f"[Login] User not found for credential: {credential}, role: {role}")
            return jsonify(error="User not found"), 401
        
        if not check_password_hash(user.password, data["password"]):
            print(f"[Login] Invalid password for user: {credential}")
            return jsonify(error="Invalid password"), 401

        # Create token with user_id as string (JWT requirement)
        token = create_access_token(identity=str(user.id))
        print(f"[Login] Successful login for user_id: {user.id}, role: {role}")
        
        return jsonify(
            access_token=token, 
            user_id=user.id,
            role=role,
            name=user.name
        ), 200
    
    except Exception as e:
        print(f"[Login Error] {str(e)}")
        traceback.print_exc()
        logger.error(f"Login error: {str(e)}", exc_info=True)
        return jsonify(error=str(e)), 500
@auth_bp.route("/verify-user", methods=["POST"])
def verify_user():
    """Verify if a user exists by credential and role"""
    try:
        data = request.json
        
        if not data or not data.get("credential") or not data.get("role"):
            return jsonify(error="Missing required fields: credential, role"), 400
        
        role = data["role"]
        credential = data.get("credential")
        
        user = None
        
        if role == "citizen":
            # Try to find by email, phone, or name
            if "@" in credential:
                user = User.query.filter_by(email=credential, role="citizen").first()
            else:
                phone_digits = ''.join(c for c in credential if c.isdigit())
                if len(phone_digits) >= 10 and phone_digits == credential.replace("-", "").replace(" ", ""):
                    user = User.query.filter_by(phone=credential, role="citizen").first()
                    if not user:
                        citizen_obj = Citizen.query.filter_by(phone=credential).first()
                        if citizen_obj:
                            user = User.query.get(citizen_obj.user_id)
                else:
                    user = User.query.filter_by(name=credential, role="citizen").first()
        else:
            # For hospital, government - search by name
            user = User.query.filter_by(name=credential, role=role).first()
        
        if user:
            print(f"[VerifyUser] User found: {credential}, role: {role}")
            return jsonify(msg="User found"), 200
        else:
            print(f"[VerifyUser] User not found: {credential}, role: {role}")
            return jsonify(error="User not found"), 401
    
    except Exception as e:
        print(f"[VerifyUser Error] {str(e)}")
        traceback.print_exc()
        logger.error(f"VerifyUser error: {str(e)}", exc_info=True)
        return jsonify(error=str(e)), 500

@auth_bp.route("/reset-password", methods=["POST"])
def reset_password():
    """Reset user password by credential"""
    try:
        data = request.json
        
        if not data or not data.get("credential") or not data.get("new_password") or not data.get("role"):
            return jsonify(error="Missing required fields: credential, new_password, role"), 400
        
        role = data["role"]
        credential = data.get("credential")
        new_password = data.get("new_password")
        
        user = None
        
        if role == "citizen":
            # Try to find by email, phone, or name
            if "@" in credential:
                user = User.query.filter_by(email=credential, role="citizen").first()
            else:
                phone_digits = ''.join(c for c in credential if c.isdigit())
                if len(phone_digits) >= 10 and phone_digits == credential.replace("-", "").replace(" ", ""):
                    user = User.query.filter_by(phone=credential, role="citizen").first()
                    if not user:
                        citizen_obj = Citizen.query.filter_by(phone=credential).first()
                        if citizen_obj:
                            user = User.query.get(citizen_obj.user_id)
                else:
                    user = User.query.filter_by(name=credential, role="citizen").first()
        else:
            # For hospital, government - search by name
            user = User.query.filter_by(name=credential, role=role).first()
        
        if not user:
            print(f"[ResetPassword] User not found: {credential}, role: {role}")
            return jsonify(error="User not found"), 401
        
        # Update password
        user.password = generate_password_hash(new_password)
        db.session.commit()
        
        print(f"[ResetPassword] Password reset successfully for user: {credential}, role: {role}")
        return jsonify(msg="Password reset successfully"), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"[ResetPassword Error] {str(e)}")
        traceback.print_exc()
        logger.error(f"ResetPassword error: {str(e)}", exc_info=True)
        return jsonify(error=str(e)), 500