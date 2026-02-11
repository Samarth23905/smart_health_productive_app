import os
import joblib
import logging

logger = logging.getLogger(__name__)

# ================================
# Load ML Model (once at startup)
# ================================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "risk_model.pkl")

try:
    model = joblib.load(MODEL_PATH)
    logger.info("[ML] Risk model loaded successfully")
except Exception as e:
    model = None
    logger.error(f"[ML] Failed to load risk model: {e}")


# ==================================
# Feature Builder (from symptom JSON)
# ==================================

def build_features(symptom_details: dict) -> dict:
    """
    Converts symptom_details JSON into ML-friendly features
    """

    symptom_count = len(symptom_details)

    severe_count = sum(1 for s in symptom_details.values() if s["severity"] == "severe")
    moderate_count = sum(1 for s in symptom_details.values() if s["severity"] == "moderate")
    mild_count = sum(1 for s in symptom_details.values() if s["severity"] == "mild")

    max_days = max(s["days"] for s in symptom_details.values())
    total_days = sum(s["days"] for s in symptom_details.values())

    has_chest_pain = int(any("chest" in k.lower() for k in symptom_details))
    has_breathlessness = int(any("breath" in k.lower() for k in symptom_details))
    has_fever = int(any("fever" in k.lower() for k in symptom_details))

    return {
        "symptom_count": symptom_count,
        "severe_count": severe_count,
        "moderate_count": moderate_count,
        "mild_count": mild_count,
        "max_days": max_days,
        "total_days": total_days,
        "has_chest_pain": has_chest_pain,
        "has_breathlessness": has_breathlessness,
        "has_fever": has_fever
    }


# ===========================
# Risk Prediction Function
# ===========================

def predict_risk_percentage(features: dict) -> int:
    """
    Predicts health risk percentage (0–100)
    """

    if model is None:
        logger.warning("[ML] Model not loaded, returning fallback risk")
        return 50  # Safe fallback

    try:
        X = [[
            features["symptom_count"],
            features["severe_count"],
            features["moderate_count"],
            features["mild_count"],
            features["max_days"],
            features["total_days"],
            features["has_chest_pain"],
            features["has_breathlessness"],
            features["has_fever"]
        ]]

        probability = model.predict_proba(X)[0][1]
        risk_percentage = int(round(probability * 100))

        logger.info(f"[ML] Predicted risk: {risk_percentage}%")
        return risk_percentage

    except Exception as e:
        logger.error(f"[ML] Prediction error: {e}")
        return 50
