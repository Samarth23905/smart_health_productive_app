CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL CHECK (role IN ('citizen', 'hospital', 'government', 'ambulance')),
    name VARCHAR(120) NOT NULL,
    email VARCHAR(120) UNIQUE,
    phone VARCHAR(20),
    profile_pic TEXT,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_name_role ON users(name, role);

CREATE TABLE citizens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    sex VARCHAR(10),
    phone VARCHAR(20),
    latitude FLOAT,
    longitude FLOAT,
    profile_pic TEXT,  
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_citizens_user_id ON citizens(user_id);
CREATE INDEX idx_citizens_location ON citizens(latitude, longitude);

CREATE TABLE hospitals (
    id SERIAL PRIMARY KEY,

    -- User relation
    user_id INTEGER NOT NULL UNIQUE
        REFERENCES users(id) ON DELETE CASCADE,

    -- Basic info
    phone VARCHAR(20),
    latitude FLOAT,
    longitude FLOAT,
    profile_pic TEXT,

    -- Bed summary
    total_beds INTEGER DEFAULT 0,
    icu_beds INTEGER DEFAULT 0,

    -- General wards
    general_total INTEGER DEFAULT 0,
    general_available INTEGER DEFAULT 0,

    semi_total INTEGER DEFAULT 0,
    semi_available INTEGER DEFAULT 0,

    private_total INTEGER DEFAULT 0,
    private_available INTEGER DEFAULT 0,

    isolation_total INTEGER DEFAULT 0,
    isolation_available INTEGER DEFAULT 0,

    -- ICU types
    micu_total INTEGER DEFAULT 0,
    micu_available INTEGER DEFAULT 0,
    micu_ventilators INTEGER DEFAULT 0,
    micu_monitors INTEGER DEFAULT 0,
    micu_oxygen BOOLEAN DEFAULT FALSE,

    sicu_total INTEGER DEFAULT 0,
    sicu_available INTEGER DEFAULT 0,
    sicu_ventilators INTEGER DEFAULT 0,
    sicu_monitors INTEGER DEFAULT 0,
    sicu_oxygen BOOLEAN DEFAULT FALSE,

    nicu_total INTEGER DEFAULT 0,
    nicu_available INTEGER DEFAULT 0,
    nicu_ventilators INTEGER DEFAULT 0,
    nicu_monitors INTEGER DEFAULT 0,
    nicu_oxygen BOOLEAN DEFAULT FALSE,

    ccu_total INTEGER DEFAULT 0,
    ccu_available INTEGER DEFAULT 0,
    ccu_ventilators INTEGER DEFAULT 0,
    ccu_monitors INTEGER DEFAULT 0,
    ccu_oxygen BOOLEAN DEFAULT FALSE,

    picu_total INTEGER DEFAULT 0,
    picu_available INTEGER DEFAULT 0,
    picu_ventilators INTEGER DEFAULT 0,
    picu_monitors INTEGER DEFAULT 0,
    picu_oxygen BOOLEAN DEFAULT FALSE,

    -- Emergency & transport
    emergency_24x7 BOOLEAN DEFAULT FALSE,
    ambulance_available BOOLEAN DEFAULT FALSE,
    ambulance_count INTEGER DEFAULT 0,

    -- Equipment & oxygen
    oxygen_available BOOLEAN DEFAULT FALSE,
    central_oxygen BOOLEAN DEFAULT FALSE,
    oxygen_cylinders INTEGER DEFAULT 0,
    defibrillator BOOLEAN DEFAULT FALSE,

    -- Diagnostics
    lab BOOLEAN DEFAULT FALSE,
    xray BOOLEAN DEFAULT FALSE,
    ecg BOOLEAN DEFAULT FALSE,
    ultrasound BOOLEAN DEFAULT FALSE,
    ct_scan BOOLEAN DEFAULT FALSE,
    mri BOOLEAN DEFAULT FALSE,

    -- Pharmacy
    in_house_pharmacy BOOLEAN DEFAULT FALSE,
    pharmacy_24x7 BOOLEAN DEFAULT FALSE,
    essential_drugs BOOLEAN DEFAULT FALSE,

    -- Staff
    doctors_count INTEGER DEFAULT 0,
    nurses_count INTEGER DEFAULT 0,
    icu_trained_staff BOOLEAN DEFAULT FALSE,
    anesthetist_available BOOLEAN DEFAULT FALSE,

    -- Facilities
    blood_bank BOOLEAN DEFAULT FALSE,
    dialysis_unit BOOLEAN DEFAULT FALSE,
    cssd BOOLEAN DEFAULT FALSE,
    mortuary BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE severities (
    id SERIAL PRIMARY KEY,
    citizen_id INTEGER NOT NULL REFERENCES citizens(id) ON DELETE CASCADE,
    symptoms TEXT NOT NULL,
    severity_level VARCHAR(20) NOT NULL CHECK (severity_level IN ('low','mild','moderate','severe','very_severe')),
	total_days_symptomatic INTEGER DEFAULT 0,
	max_severity VARCHAR(20) DEFAULT 'low',
	symptom_details JSONB DEFAULT NULL,
    risk_percentage INTEGER,
    report_generated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE severities
ADD COLUMN risk_percentage INTEGER,
ADD COLUMN report_generated BOOLEAN DEFAULT FALSE;



CREATE INDEX IF NOT EXISTS idx_severities_max_severity ON severities(max_severity);
CREATE INDEX IF NOT EXISTS idx_severities_citizen_date ON severities(citizen_id, created_at DESC);
CREATE INDEX idx_severities_citizen_id ON severities(citizen_id);
CREATE INDEX idx_severities_severity_level ON severities(severity_level);
CREATE INDEX idx_severities_created_at ON severities(created_at DESC);

CREATE TABLE ambulance_alerts (
    id SERIAL PRIMARY KEY,
    citizen_id INTEGER NOT NULL REFERENCES citizens(id) ON DELETE CASCADE,
    hospital_id INTEGER NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
	ambulance_latitude  DOUBLE PRECISION,
    ambulance_longitude DOUBLE PRECISION,
    status VARCHAR(30) NOT NULL DEFAULT 'dispatched' CHECK (status IN (
        'dispatched',
        'on_the_way',
        'arrived',
        'picked_up',
        'en_route_to_hospital',
        'delivered'
    )),
    eta_minutes INTEGER,
	ambulance_speed_kmh FLOAT DEFAULT 0,
	prev_ambulance_latitude FLOAT,
	prev_ambulance_longitude FLOAT,
	last_location_update TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	delivered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ambulance_alerts_speed ON ambulance_alerts(ambulance_speed_kmh);
CREATE INDEX idx_ambulance_alerts_location ON ambulance_alerts(ambulance_latitude, ambulance_longitude);
CREATE INDEX idx_ambulance_alerts_citizen_id ON ambulance_alerts(citizen_id);
CREATE INDEX idx_ambulance_alerts_hospital_id ON ambulance_alerts(hospital_id);
CREATE INDEX idx_ambulance_alerts_status ON ambulance_alerts(status);
CREATE INDEX idx_ambulance_alerts_created_at ON ambulance_alerts(created_at DESC);

CREATE TABLE government_analysis (
    id SERIAL PRIMARY KEY,
    report_date DATE DEFAULT CURRENT_DATE UNIQUE,
    
    -- Severity Metrics (Count)
    mild_cases INTEGER DEFAULT 0,
    moderate_cases INTEGER DEFAULT 0,
    severe_cases INTEGER DEFAULT 0,
    very_severe_cases INTEGER DEFAULT 0,
    total_severity_cases INTEGER DEFAULT 0,
    
    -- Severity Distribution (Percentages)
    mild_percentage FLOAT DEFAULT 0,
    moderate_percentage FLOAT DEFAULT 0,
    severe_percentage FLOAT DEFAULT 0,
    very_severe_percentage FLOAT DEFAULT 0,
    
    -- Alert Metrics (Count)
    total_alerts INTEGER DEFAULT 0,
    dispatched_alerts INTEGER DEFAULT 0,
    on_way_alerts INTEGER DEFAULT 0,
    arrived_alerts INTEGER DEFAULT 0,
    completed_alerts INTEGER DEFAULT 0,
    
    -- ETA Statistics (in minutes)
    eta_mean FLOAT DEFAULT 0,
    eta_median FLOAT DEFAULT 0,
    eta_std_dev FLOAT DEFAULT 0,
    eta_min FLOAT DEFAULT 0,
    eta_max FLOAT DEFAULT 0,
    eta_q25 FLOAT DEFAULT 0,
    eta_q75 FLOAT DEFAULT 0,
    
    -- Performance Metrics
    success_rate_percentage FLOAT DEFAULT 0,
    average_response_time FLOAT DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_government_analysis_date ON government_analysis(report_date DESC);
