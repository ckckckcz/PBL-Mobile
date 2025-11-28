"""
Model loading and management service
"""

import joblib
from pathlib import Path
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class ModelService:
    """
    Service for loading and managing ML models
    """

    def __init__(self, model_path: Path):
        """
        Initialize model service with model path

        Args:
            model_path: Path to the model file
        """
        self.model_path = model_path
        self.model: Optional[Dict[str, Any]] = None

    def load_model(self) -> Dict[str, Any]:
        """
        Load model from disk

        Returns:
            Dict containing model components

        Raises:
            Exception: If model loading fails
        """
        try:
            logger.info(f"[MODEL] Loading XGBoost Hybrid model from: {self.model_path}")
            logger.info(f"[MODEL] Model exists: {self.model_path.exists()}")

            if not self.model_path.exists():
                raise FileNotFoundError(f"Model file not found at {self.model_path}")

            self.model = joblib.load(self.model_path)

            logger.info(f"[MODEL] ✓ Model loaded successfully!")
            logger.info(f"[MODEL] Model type: {type(self.model)}")

            if isinstance(self.model, dict):
                logger.info(f"[MODEL] Model components: {list(self.model.keys())}")

            return self.model

        except Exception as e:
            logger.error(f"[MODEL] ✗ Error loading model: {e}")
            logger.exception(e)
            self.model = None
            raise

    def is_loaded(self) -> bool:
        """
        Check if model is loaded

        Returns:
            bool: True if model is loaded, False otherwise
        """
        return self.model is not None

    def get_model(self) -> Optional[Dict[str, Any]]:
        """
        Get loaded model

        Returns:
            Dict containing model components or None if not loaded
        """
        return self.model


# Global model service instance
_model_service: Optional[ModelService] = None


def init_model_service(model_path: Path) -> ModelService:
    """
    Initialize global model service

    Args:
        model_path: Path to the model file

    Returns:
        ModelService instance
    """
    global _model_service
    _model_service = ModelService(model_path)
    return _model_service


def get_model_service() -> Optional[ModelService]:
    """
    Get global model service instance

    Returns:
        ModelService instance or None if not initialized
    """
    return _model_service
