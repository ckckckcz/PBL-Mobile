from xgboost import XGBClassifier
import joblib
import numpy as np
from pathlib import Path
from typing import Dict, Any, Optional
import logging


logger = logging.getLogger(__name__)

# Global model service instance
_model_service: Optional['ModelService'] = None


class ModelService:
    def __init__(self, base_dir: Optional[Path] = None):
        # Auto resolve BASE_DIR = backend/
        if base_dir:
            self.BASE_DIR = Path(base_dir)
        else:
            self.BASE_DIR = Path(__file__).resolve().parents[2]

        # Hardcoded path (aman & konsisten)
        self.artifacts_path = self.BASE_DIR / "model" / "artifacts.pkl"
        self.model_json_path = self.BASE_DIR / "model" / "xgb_model.json"

        self.model: Optional[Dict[str, Any]] = None
        self.is_validated = False

        logger.info("[MODEL] ModelService created")

    def _safe_setattr(self, obj: Any, name: str, value: Any) -> None:
        try:
            setattr(obj, name, value)
        except AttributeError:
            obj.__dict__[name] = value

    def _restore_model_metadata(self, xgb_model: XGBClassifier, artifacts: Dict[str, Any]) -> None:
        label_encoder = artifacts.get("label_encoder")
        classes = None


        if label_encoder is not None and hasattr(label_encoder, "classes_"):

            classes_attr = getattr(label_encoder, "classes_", None)

            if classes_attr is not None and len(classes_attr) > 0:

                classes = np.asarray(classes_attr, dtype=object)
                xgb_model._le = label_encoder

                xgb_model.label_encoder_ = label_encoder

        if classes is None:

            waste_map = artifacts.get("waste_map")

            if waste_map:

                classes = np.asarray(list(waste_map.keys()), dtype=object)



        if classes is not None and len(classes) > 0:

            self._safe_setattr(xgb_model, "n_classes_", len(classes))
            self._safe_setattr(xgb_model, "_n_classes", len(classes))
        elif hasattr(xgb_model, "_le") and hasattr(xgb_model._le, "classes_"):
            classes_from_encoder = getattr(xgb_model._le, "classes_", None)
            if classes_from_encoder is not None and len(classes_from_encoder) > 0:
                self._safe_setattr(xgb_model, "n_classes_", len(classes_from_encoder))
                self._safe_setattr(xgb_model, "_n_classes", len(classes_from_encoder))


        feature_columns = artifacts.get("feature_columns")
        if feature_columns:
            self._safe_setattr(xgb_model, "n_features_in_", len(feature_columns))
            self._safe_setattr(
                xgb_model,
                "feature_names_in_",
                np.asarray(feature_columns, dtype=object)
            )
        else:
            total_features = artifacts.get("total_features", getattr(xgb_model, "n_features_in_", 38))
            self._safe_setattr(xgb_model, "n_features_in_", total_features)
            existing_names = getattr(xgb_model, "feature_names_in_", None)
            if existing_names is None or len(existing_names) != total_features:
                self._safe_setattr(
                    xgb_model,
                    "feature_names_in_",
                    np.asarray(
                        [f"feature_{i}" for i in range(total_features)],
                        dtype=object
                    )
                )









    def load_model(self) -> Dict[str, Any]:
        logger.info(f"[MODEL] Loading artifacts from: {self.artifacts_path}")
        logger.info(f"[MODEL] Loading XGB model from: {self.model_json_path}")

        if not self.artifacts_path.exists():
            raise FileNotFoundError(f"Artifacts not found: {self.artifacts_path}")

        if not self.model_json_path.exists():
            raise FileNotFoundError(f"Model JSON not found: {self.model_json_path}")


        # Load artifacts

        artifacts = joblib.load(self.artifacts_path)



        # Load XGBoost model

        xgb_model = XGBClassifier()

        xgb_model.load_model(str(self.model_json_path))

        self._restore_model_metadata(xgb_model, artifacts)
        logger.info("[MODEL] ✓ Restored sklearn metadata for XGB model")

        # Merge artifacts + model

        self.model = {

            "model": xgb_model,

            **artifacts

        }


        logger.info(f"[MODEL] Loaded keys: {list(self.model.keys())}")

        self.validate_model()
        return self.model

    def validate_model(self) -> None:
        if not self.model:
            raise ValueError("Model not loaded")

        required = ["model", "scaler", "label_encoder", "waste_map"]

        missing = [k for k in required if k not in self.model]

        if missing:
            raise ValueError(f"Missing required keys: {missing}")

        logger.info("[MODEL] ✓ Model validated")
        self.is_validated = True

    def get_model(self):
        if not self.model:
            raise RuntimeError("Model not loaded")
        return self.model

    def is_loaded(self) -> bool:
        """Check if model is loaded and validated"""
        return self.model is not None and self.is_validated

    def get_model_info(self) -> Dict[str, Any]:
        """Get information about loaded model"""
        if not self.is_loaded():
            return {
                "loaded": False,
                "validated": False,
                "source": None,
                "components": []
            }

        # Extract additional info from model
        n_classes = None
        waste_classes = []
        threshold = 0.6  # Default threshold

        if self.model:
            # Get number of classes from label encoder
            if "label_encoder" in self.model:
                waste_classes = list(self.model["label_encoder"].classes_)
                n_classes = len(waste_classes)

            # Get threshold if available
            if "threshold" in self.model:
                threshold = self.model["threshold"]

        return {
            "loaded": True,
            "validated": self.is_validated,
            "source": "xgb_model.json + artifacts.pkl",
            "components": list(self.model.keys()) if self.model else [],
            "artifacts_path": str(self.artifacts_path),
            "model_path": str(self.model_json_path),
            "n_classes": n_classes,
            "waste_classes": waste_classes,
            "threshold": threshold
        }


def init_model_service(base_dir: Optional[Path] = None) -> ModelService:
    """
    Initialize model service

    Args:
        base_dir: Base directory path (optional)

    Returns:
        ModelService instance
    """
    global _model_service
    _model_service = ModelService(base_dir=base_dir)
    logger.info("[SERVICE] ✓ Model service initialized")
    return _model_service


def get_model_service() -> Optional[ModelService]:
    """
    Get model service instance

    Returns:
        ModelService instance or None if not initialized
    """
    return _model_service
