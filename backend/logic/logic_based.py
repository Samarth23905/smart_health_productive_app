# logic_based.py

def determine_risk_level(risk_percentage: int) -> str:
    if risk_percentage < 30:
        return "Low"
    elif risk_percentage < 50:
        return "Mild"
    elif risk_percentage < 70:
        return "Moderate"
    elif risk_percentage < 85:
        return "High"
    else:
        return "Critical"


# =========================================
# PRECAUTIONS LOGIC
# =========================================

def generate_precautions(symptom_details: dict, risk_percentage: int) -> list:
    precautions = set()

    # General precautions
    precautions.add("Monitor symptoms regularly")
    precautions.add("Stay hydrated and take adequate rest")

    # Risk-based precautions
    if risk_percentage >= 70:
        precautions.add("Seek medical attention immediately")
        precautions.add("Avoid physical exertion")
    elif risk_percentage >= 50:
        precautions.add("Consult a doctor within 24 hours")
    else:
        precautions.add("Continue home care and observe symptoms")

    # Symptom-based precautions
    for symptom in symptom_details.keys():
        s = symptom.lower()

        if "chest" in s:
            precautions.add("Avoid physical strain and stress")
            precautions.add("Do not ignore chest discomfort")

        if "breath" in s:
            precautions.add("Sit upright and avoid lying flat")
            precautions.add("Ensure proper ventilation")

        if "fever" in s:
            precautions.add("Monitor body temperature regularly")
            precautions.add("Use antipyretics only if prescribed")

        if "headache" in s or "dizziness" in s:
            precautions.add("Avoid driving or operating heavy machinery")

        if "vomit" in s or "loose" in s:
            precautions.add("Maintain electrolyte balance")

    return sorted(list(precautions))


# =========================================
# REQUIRED HOSPITAL RESOURCES LOGIC
# =========================================

SYMPTOM_TO_RESOURCES = {
    "chest pain": {"icu", "ccu", "ventilator", "oxygen", "ecg", "lab"},
    "breathlessness": {"icu", "ventilator", "oxygen"},
    "trouble breathing": {"icu", "ventilator", "oxygen"},
    "fever": {"lab", "oxygen", "isolation"},
    "seizures": {"icu", "ct_scan", "mri"},
    "headache": {"ct_scan", "mri"},
    "vomiting": {"lab", "iv_fluids"},
    "blood cough": {"icu", "ventilator", "lab"},
    "fainting": {"icu", "ecg"},
}


def determine_required_resources(symptom_details: dict, risk_percentage: int) -> list:
    required_resources = set()

    # Base resources based on symptoms
    for symptom in symptom_details.keys():
        s = symptom.lower()
        for key, resources in SYMPTOM_TO_RESOURCES.items():
            if key in s:
                required_resources.update(resources)

    # Risk escalation
    if risk_percentage >= 85:
        required_resources.update({"icu", "ventilator", "24x7_emergency"})
    elif risk_percentage >= 70:
        required_resources.update({"oxygen", "icu"})

    # Always required
    required_resources.add("lab")
    required_resources.add("24x7_emergency")

    return sorted(list(required_resources))


# =========================================
# MAIN REPORT GENERATOR
# =========================================

def generate_health_report(
    symptom_details: dict,
    risk_percentage: int,
    max_severity: str,
    total_days_symptomatic: int
) -> dict:

    risk_level = determine_risk_level(risk_percentage)

    precautions = generate_precautions(symptom_details, risk_percentage)
    required_resources = determine_required_resources(symptom_details, risk_percentage)

    report = {
        "risk_percentage": risk_percentage,
        "risk_level": risk_level,
        "max_severity": max_severity,
        "total_days_symptomatic": total_days_symptomatic,
        "current_symptoms": list(symptom_details.keys()),
        "precautions": precautions,
        "required_hospital_resources": required_resources
    }

    return report
