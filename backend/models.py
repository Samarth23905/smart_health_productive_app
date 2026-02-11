from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    role = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=True)
    phone = db.Column(db.String(20))
    profile_pic = db.Column(db.Text)  # base64 encoded image
    password = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Citizen(db.Model):
    __tablename__ = 'citizens'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    sex = db.Column(db.String(10))
    phone = db.Column(db.String(20))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    profile_pic = db.Column(db.Text)  # base64 encoded image
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Hospital(db.Model):
    __tablename__ = 'hospitals'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    phone = db.Column(db.String(20))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    total_beds = db.Column(db.Integer, default=0)
    icu_beds = db.Column(db.Integer, default=0)
    oxygen_available = db.Column(db.Boolean, default=False)
    profile_pic = db.Column(db.Text)  # base64 encoded image
    # Ward resources
    general_total = db.Column(db.Integer, default=0)
    general_available = db.Column(db.Integer, default=0)
    semi_total = db.Column(db.Integer, default=0)
    semi_available = db.Column(db.Integer, default=0)
    private_total = db.Column(db.Integer, default=0)
    private_available = db.Column(db.Integer, default=0)
    isolation_total = db.Column(db.Integer, default=0)
    isolation_available = db.Column(db.Integer, default=0)

    # ICU breakdowns
    micu_total = db.Column(db.Integer, default=0)
    micu_available = db.Column(db.Integer, default=0)
    micu_ventilators = db.Column(db.Integer, default=0)
    micu_monitors = db.Column(db.Integer, default=0)
    micu_oxygen = db.Column(db.Boolean, default=False)

    sicu_total = db.Column(db.Integer, default=0)
    sicu_available = db.Column(db.Integer, default=0)
    sicu_ventilators = db.Column(db.Integer, default=0)
    sicu_monitors = db.Column(db.Integer, default=0)
    sicu_oxygen = db.Column(db.Boolean, default=False)

    nicu_total = db.Column(db.Integer, default=0)
    nicu_available = db.Column(db.Integer, default=0)
    nicu_ventilators = db.Column(db.Integer, default=0)
    nicu_monitors = db.Column(db.Integer, default=0)
    nicu_oxygen = db.Column(db.Boolean, default=False)

    ccu_total = db.Column(db.Integer, default=0)
    ccu_available = db.Column(db.Integer, default=0)
    ccu_ventilators = db.Column(db.Integer, default=0)
    ccu_monitors = db.Column(db.Integer, default=0)
    ccu_oxygen = db.Column(db.Boolean, default=False)

    picu_total = db.Column(db.Integer, default=0)
    picu_available = db.Column(db.Integer, default=0)
    picu_ventilators = db.Column(db.Integer, default=0)
    picu_monitors = db.Column(db.Integer, default=0)
    picu_oxygen = db.Column(db.Boolean, default=False)

    # Emergency & life-saving
    emergency_24x7 = db.Column(db.Boolean, default=False)
    ambulance_available = db.Column(db.Boolean, default=False)
    ambulance_count = db.Column(db.Integer, default=0)
    defibrillator = db.Column(db.Boolean, default=False)
    central_oxygen = db.Column(db.Boolean, default=False)

    # Diagnostics
    lab = db.Column(db.Boolean, default=False)
    xray = db.Column(db.Boolean, default=False)
    ecg = db.Column(db.Boolean, default=False)
    ultrasound = db.Column(db.Boolean, default=False)
    ct_scan = db.Column(db.Boolean, default=False)
    mri = db.Column(db.Boolean, default=False)

    # Pharmacy & supplies
    in_house_pharmacy = db.Column(db.Boolean, default=False)
    pharmacy_24x7 = db.Column(db.Boolean, default=False)
    oxygen_cylinders = db.Column(db.Integer, default=0)
    essential_drugs = db.Column(db.Boolean, default=False)

    # Human resources
    doctors_count = db.Column(db.Integer, default=0)
    nurses_count = db.Column(db.Integer, default=0)
    icu_trained_staff = db.Column(db.Boolean, default=False)
    anesthetist_available = db.Column(db.Boolean, default=False)

    # Support resources
    blood_bank = db.Column(db.Boolean, default=False)
    dialysis_unit = db.Column(db.Boolean, default=False)
    cssd = db.Column(db.Boolean, default=False)
    mortuary = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class AmbulanceAlert(db.Model):
    __tablename__ = 'ambulance_alerts'
    id = db.Column(db.Integer, primary_key=True)
    citizen_id = db.Column(db.Integer, db.ForeignKey('citizens.id'), nullable=False)
    hospital_id = db.Column(db.Integer, db.ForeignKey('hospitals.id'), nullable=False)
    status = db.Column(db.String(30), default='dispatched', nullable=False)  # dispatched, on_the_way, arrived, picked_up, en_route_to_hospital, delivered
    eta_minutes = db.Column(db.Integer)
    ambulance_latitude = db.Column(db.Float, nullable=True)  # Ambulance's current location
    ambulance_longitude = db.Column(db.Float, nullable=True)  # Ambulance's current location

    # Real-time speed tracking
    ambulance_speed_kmh = db.Column(db.Float, default=0)  # Current calculated speed in km/h
    prev_ambulance_latitude = db.Column(db.Float, nullable=True)  # Previous location for speed calculation
    prev_ambulance_longitude = db.Column(db.Float, nullable=True)  # Previous location for speed calculation
    last_location_update = db.Column(db.DateTime, nullable=True)  # Timestamp of last location update

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    delivered_at = db.Column(db.DateTime, nullable=True)

class Severity(db.Model):
    __tablename__ = 'severities'
    id = db.Column(db.Integer, primary_key=True)
    citizen_id = db.Column(db.Integer, db.ForeignKey('citizens.id'), nullable=False)
    symptoms = db.Column(db.Text, nullable=False)  # Stored as comma-separated string (set format)
    severity_level = db.Column(db.String(20), default='low')  # low, moderate, severe (DEPRECATED - use max_severity)

    # NEW FIELDS: Store detailed symptom information
    symptom_details = db.Column(db.JSON, default=None)  # JSON: {"Chest Pain": {"days": 3, "severity": "severe"}, ...}
    max_severity = db.Column(db.String(20), default='low')  # Most severe symptom: mild, moderate, severe
    total_days_symptomatic = db.Column(db.Integer, default=0)  # Duration of longest symptom
    risk_percentage = db.Column(db.Integer, default=0)  # ML-predicted risk (0-100)
    report_generated = db.Column(db.Boolean, default=False)  # Whether health report was generated

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def set_symptoms(self, symptoms_list):
        """Store symptoms as a set (comma-separated, unique values)"""
        unique_symptoms = set(symptoms_list)
        self.symptoms = ",".join(sorted(unique_symptoms))

    def set_symptom_details(self, symptom_details_dict):
        """
        Store detailed symptom information
        Format: {"Chest Pain": {"days": 3, "severity": "severe"}, ...}
        """
        self.symptom_details = symptom_details_dict

        # Calculate max_severity
        if symptom_details_dict:
            severity_rank = {"mild": 1, "moderate": 2, "severe": 3}
            max_sev_rank = max(
                [severity_rank.get(d.get("severity", "mild"), 0)
                 for d in symptom_details_dict.values()],
                default=0
            )
            severity_map = {0: "low", 1: "mild", 2: "moderate", 3: "severe"}
            self.max_severity = severity_map.get(max_sev_rank, "low")

            # Calculate total days symptomatic (longest duration)
            self.total_days_symptomatic = max(
                [d.get("days", 0) for d in symptom_details_dict.values()],
                default=0
            )
        else:
            self.max_severity = "low"
            self.total_days_symptomatic = 0

    def get_symptoms(self):
        """Retrieve symptoms as a list"""
        if not self.symptoms:
            return []
        return self.symptoms.split(",")

    def get_symptoms_set(self):
        """Retrieve symptoms as a set"""
        if not self.symptoms:
            return set()
        return set(self.symptoms.split(","))

    def get_symptom_details(self):
        """Retrieve detailed symptom information with days and severity"""
        return self.symptom_details if self.symptom_details else {}

    def __repr__(self):
        return f'<Severity {self.id}: {self.get_symptoms_set()} (Max: {self.max_severity})>'
