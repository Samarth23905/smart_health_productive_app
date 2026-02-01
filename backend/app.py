from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from models import db
from routes.auth import auth_bp
from routes.citizen import citizen_bp
from routes.hospital import hospital_bp
from routes.ambulance import ambulance_bp
from routes.government import government_bp
from routes.citizen_profile import citizen_profile_bp
from routes.hospital_profile import hospital_profile_bp
from routes.Symptoms_form import symptoms_form_bp
import os
import logging

# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config.from_object("config")

# Debug: Print database URI
db_uri = app.config.get('SQLALCHEMY_DATABASE_URI')
if db_uri:
    masked_uri = db_uri[:50] + "..." if len(db_uri) > 50 else db_uri
    logger.info(f"Database URI: {masked_uri}")
else:
    logger.error("❌ DATABASE_URL not configured! Check environment variables.")

# Enable CORS for all routes and allow credentials (so browser preflight requests succeed)
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
db.init_app(app)
JWTManager(app)

@app.route("/")
def home():
    return {"status": "Smart Health API is running", "version": "1.0"}

@app.route("/db-test")
def db_test():
    try:
        result = db.session.execute(db.text("SELECT 1"))
        return {"status": "Database connection successful", "result": str(result.fetchone())}
    except Exception as e:
        logger.error(f"Database test failed: {e}")
        return {"status": "Database connection failed", "error": str(e)}, 500

@app.errorhandler(404)
def not_found(error):
    return {"error": "Endpoint not found"}, 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal Server Error: {error}")
    db.session.rollback()
    return {"error": "Internal server error"}, 500


app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(citizen_bp, url_prefix="/citizen")
app.register_blueprint(citizen_profile_bp, url_prefix="/citizen")
app.register_blueprint(hospital_bp, url_prefix="/hospital")
app.register_blueprint(hospital_profile_bp, url_prefix="/hospital")
app.register_blueprint(ambulance_bp, url_prefix="/ambulance")
app.register_blueprint(government_bp, url_prefix="/government")
app.register_blueprint(symptoms_form_bp, url_prefix="/symptoms")

if __name__ == "__main__":
    try:
        with app.app_context():
            db.create_all()
            logger.info("✓ Database tables created/verified")
    except Exception as e:
        logger.error(f"✗ Database initialization failed: {e}")
    
    # Get port from environment or use default
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
