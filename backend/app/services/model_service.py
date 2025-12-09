"""
Model loading and management service
Hugging Face ready – strict validation, no silent failures
"""

import joblib
from pathlib import Path
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class ModelService:
    """
    Strict model loader with hard validation
    """

    def __init__(self, model_path: Path):
        self.model_path = model_path
        self.model: Optional[Dict[str, Any]] = None
        self.is_validated: bool = False

    def load_model(self) -> Dict[str, Any]:
        logger.info(f"[MODEL] Loading model from: {self.model_path}")

        if not self.model_path.exists():
            raise FileNotFoundError(f"Model file not found: {self.model_path}")

        try:
            self.model = joblib.load(self.model_path)
        except Exception as e:
            logger.exception("[MODEL] Failed to load model file")
            raise RuntimeError(f"Model load failed: {e}")

        if not isinstance(self.model, dict):
            raise ValueError(f"Loaded object must be dict, got {type(self.model)}")

        logger.info(f"[MODEL] Model keys: {list(self.model.keys())}")

        self.validate_model()
        return self.model

    def validate_model(self) -> None:
        if self.model is None:
            raise ValueError("Model is None")

        required_keys = [
            "model",
            "scaler",
            "label_encoder",
            "waste_map"
        ]

        missing = [k for k in required_keys if k not in self.model]
        if missing:
            raise ValueError(f"Missing required keys: {missing}")

        model = self.model["model"]
        scaler = self.model["scaler"]
        encoder = self.model["label_encoder"]
        waste_map = self.model["waste_map"]

        # Hard method checks
        if not hasattr(model, "predict"):
            raise ValueError("Model missing predict()")

        if not hasattr(model, "predict_proba"):
            raise ValueError("Model missing predict_proba() – you rely on this")

        if not hasattr(scaler, "transform"):
            raise ValueError("Scaler missing transform()")

        if not hasattr(encoder, "classes_"):
            raise ValueError("LabelEncoder missing classes_")

        if not isinstance(waste_map, dict):
            raise ValueError("waste_map must be dict")

        if len(encoder.classes_) == 0:
            raise ValueError("LabelEncoder has no classes")

        logger.info("[MODEL] ✓ Model structure fully validated")
        self.is_validated = True

    def is_loaded(self) -> bool:
        return self.model is not None and self.is_validated

    def get_model(self) -> Dict[str, Any]:
        if not self.is_loaded():
            raise RuntimeError("Model not loaded or failed validation")
        return self.model

    def get_model_info(self) -> Dict[str, Any]:
        if not self.is_loaded():
            return {"loaded": False, "validated": False}

        enc = self.model["label_encoder"]

        return {
            "loaded": True,
            "validated": True,
            "source": str(self.model_path),
            "components": list(self.model.keys()),
            "n_classes": len(enc.classes_),
            "classes": list(enc.classes_),
            "threshold": self.model.get("threshold", 0.6),
            "version": self.model.get("version", "unknown"),
            "description": self.model.get("description", "No description available"),
            "total_features": self.model.get("total_features", "unknown")
        }


# Global singleton
_model_service: Optional[ModelService] = None


def init_model_service(model_path: Path) -> ModelService:
    global _model_service

    if _model_service is None:
        _model_service = ModelService(model_path)
        logger.info("[MODEL] ModelService singleton created")

    return _model_service


def get_model_service() -> Optional[ModelService]:
    return _model_service
