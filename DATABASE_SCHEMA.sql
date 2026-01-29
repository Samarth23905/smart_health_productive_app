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
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    phone VARCHAR(20),
    latitude FLOAT,
    longitude FLOAT,
    total_beds INTEGER,
    icu_beds INTEGER,
    oxygen_available BOOLEAN DEFAULT TRUE,
    profile_pic TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hospitals_user_id ON hospitals(user_id);
CREATE INDEX idx_hospitals_location ON hospitals(latitude, longitude);
CREATE INDEX idx_hospitals_oxygen ON hospitals(oxygen_available);

CREATE TABLE severities (
    id SERIAL PRIMARY KEY,
    citizen_id INTEGER NOT NULL REFERENCES citizens(id) ON DELETE CASCADE,
    symptoms TEXT NOT NULL,
    severity_level VARCHAR(20) NOT NULL CHECK (severity_level IN ('mild', 'moderate', 'severe')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_severities_citizen_id ON severities(citizen_id);
CREATE INDEX idx_severities_severity_level ON severities(severity_level);
CREATE INDEX idx_severities_created_at ON severities(created_at DESC);

CREATE TABLE ambulance_alerts (
    id SERIAL PRIMARY KEY,
    citizen_id INTEGER NOT NULL REFERENCES citizens(id) ON DELETE CASCADE,
    hospital_id INTEGER NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'dispatched' CHECK (status IN (
        'dispatched',
        'on_the_way',
        'arrived',
        'picked_up',
        'en_route_to_hospital',
        'delivered'
    )),
    eta_minutes INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	delivered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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


select * from users;