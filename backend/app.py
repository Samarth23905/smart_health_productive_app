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
import threading

# Setup logging
logging.basicConfig(level=logging.INFO)  # Production: INFO level
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config.from_object("config")

# Check database URI
db_uri = app.config.get('SQLALCHEMY_DATABASE_URI')
if db_uri:
    masked_uri = db_uri[:50] + "..." if len(db_uri) > 50 else db_uri
    logger.info(f"Database URI configured: {masked_uri}")
else:
    logger.warning("⚠ DATABASE_URL not configured")

# Enable CORS
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
db.init_app(app)
JWTManager(app)

# Initialize DB in background thread (non-blocking)
def init_db_async():
    """Initialize database tables in background - doesn't block startup"""
    if not db_uri:
        logger.warning("⚠ Skipping database init: DATABASE_URL not set")
        return
    try:
        with app.app_context():
            db.create_all()
            logger.info("✓ Database tables initialized")
    except Exception as e:
        logger.error(f"⚠ Database init failed: {e}")

# Start DB init in background thread immediately (non-blocking)
db_init_thread = threading.Thread(target=init_db_async, daemon=True)
db_init_thread.start()

@app.route("/")
def home():
    return {"status": "Smart Health API is running", "version": "1.0"}

@app.route("/health")
def health():
    """Health check endpoint - doesn't require database"""
    return {"status": "healthy"}, 200

@app.route("/db-test")
def db_test():
    """Test database connection"""
    if not db_uri:
        return {"status": "Database not configured", "error": "DATABASE_URL env var not set"}, 503
    try:
        result = db.session.execute(db.text("SELECT 1"))
        return {"status": "Database connection successful", "result": str(result.fetchone())}
    except Exception as e:
        logger.error(f"Database test failed: {e}")
        return {"status": "Database connection failed", "error": str(e)}, 503

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
    # Get port from environment or use default
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
