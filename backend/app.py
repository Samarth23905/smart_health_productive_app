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

app = Flask(__name__)
app.config.from_object("config")

# Debug: Print database URI
print(f"Database URI: {app.config.get('SQLALCHEMY_DATABASE_URI')}")

CORS(app)
db.init_app(app)
JWTManager(app)

@app.route("/")
def home():
    return {"status": "Smart Health API is running"}

@app.route("/db-test")
def db_test():
    try:
        result = db.session.execute(db.text("SELECT 1"))
        return {"status": "Database connection successful", "result": str(result.fetchone())}
    except Exception as e:
        return {"status": "Database connection failed", "error": str(e)}, 500


app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(citizen_bp, url_prefix="/citizen")
app.register_blueprint(citizen_profile_bp, url_prefix="/citizen")
app.register_blueprint(hospital_bp, url_prefix="/hospital")
app.register_blueprint(hospital_profile_bp, url_prefix="/hospital")
app.register_blueprint(ambulance_bp, url_prefix="/ambulance")
app.register_blueprint(government_bp, url_prefix="/government")
app.register_blueprint(symptoms_form_bp, url_prefix="/symptoms")

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
        app.run(debug=True)
