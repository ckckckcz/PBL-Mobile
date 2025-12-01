"""
Model loading and management service with Supabase Storage support
"""

import joblib
import pickle
import requests
from pathlib import Path
from typing import Dict, Any, Optional
import logging
import os

logger = logging.getLogger(__name__)


class ModelService:
    """
    Service for loading and managing ML models from Supabase Storage or local file
    """

    def __init__(self, model_path: Optional[Path] = None, model_url: Optional[str] = None):
        """
        Initialize model service with model path or URL

        Args:
            model_path: Path to the local model file (fallback)
            model_url: URL to model in Supabase Storage (primary)
        """
        self.model_path = model_path
        self.model_url = model_url or os.getenv("MODEL_URL")
        self.model: Optional[Dict[str, Any]] = None
        self.model_source: Optional[str] = None  # 'supabase' or 'local'
        self.is_validated: bool = False

    def load_model_from_supabase(self) -> Dict[str, Any]:
        """
        Load model from Supabase Storage

        Returns:
            Dict containing model components

        Raises:
            Exception: If model loading from Supabase fails
        """
        try:
            if not self.model_url:
                raise ValueError("MODEL_URL not configured")

            logger.info(f"[MODEL] Downloading model from Supabase Storage...")
            logger.info(f"[MODEL] URL: {self.model_url}")

            # Download model from Supabase
            response = requests.get(self.model_url, timeout=60)
            response.raise_for_status()

            logger.info(f"[MODEL] Model downloaded successfully ({len(response.content)} bytes)")

            # Load model from bytes
            model = pickle.loads(response.content)

            logger.info(f"[MODEL] ✓ Model loaded from Supabase!")
            logger.info(f"[MODEL] Model type: {type(model)}")

            if isinstance(model, dict):
                logger.info(f"[MODEL] Model components: {list(model.keys())}")

            self.model_source = "supabase"
            return model

        except requests.exceptions.RequestException as e:
            logger.error(f"[MODEL] ✗ Network error downloading model from Supabase: {e}")
            raise
        except pickle.UnpicklingError as e:
            logger.error(f"[MODEL] ✗ Error unpickling model: {e}")
            raise
        except Exception as e:
            logger.error(f"[MODEL] ✗ Unexpected error loading model from Supabase: {e}")
            logger.exception(e)
            raise

    def load_model_from_local(self) -> Dict[str, Any]:
        """
        Load model from local disk

        Returns:
            Dict containing model components

        Raises:
            Exception: If model loading from local fails
        """
        try:
            logger.info(f"[MODEL] Loading model from local file: {self.model_path}")
            logger.info(f"[MODEL] Model exists: {self.model_path.exists()}")

            if not self.model_path.exists():
                raise FileNotFoundError(f"Model file not found at {self.model_path}")

            model = joblib.load(self.model_path)

            logger.info(f"[MODEL] ✓ Model loaded from local file!")
            logger.info(f"[MODEL] Model type: {type(model)}")

            if isinstance(model, dict):
                logger.info(f"[MODEL] Model components: {list(model.keys())}")

            self.model_source = "local"
            return model

        except Exception as e:
            logger.error(f"[MODEL] ✗ Error loading model from local: {e}")
            logger.exception(e)
            raise

    def load_model(self) -> Dict[str, Any]:
        """
        Load model with fallback strategy:
        1. Try loading from Supabase Storage (if URL configured)
        2. Fall back to local file if Supabase fails

        Returns:
            Dict containing model components

        Raises:
            Exception: If all loading methods fail
        """
        # Try Supabase first if URL is configured
        if self.model_url:
            try:
                logger.info("[MODEL] Attempting to load model from Supabase Storage...")
                self.model = self.load_model_from_supabase()
                logger.info(f"[MODEL] ✓ Successfully loaded model from Supabase")
                self.validate_model()
                return self.model
            except Exception as e:
                logger.warning(f"[MODEL] ⚠ Failed to load from Supabase: {e}")
                logger.info("[MODEL] Falling back to local file...")

        # Fall back to local file
        if self.model_path:
            try:
                self.model = self.load_model_from_local()
                logger.info(f"[MODEL] ✓ Successfully loaded model from local file")
                self.validate_model()
                return self.model
            except Exception as e:
                logger.error(f"[MODEL] ✗ Failed to load from local file: {e}")
                raise

        raise Exception("No model source configured (neither URL nor path)")

    def validate_model(self) -> bool:
        """
        Validate that the loaded model has all required components

        Returns:
            bool: True if model is valid, False otherwise

        Raises:
            ValueError: If model validation fails
        """
        try:
            if not self.model:
                raise ValueError("Model is not loaded")

            if not isinstance(self.model, dict):
                raise ValueError(f"Model must be a dict, got {type(self.model)}")

            # Check required components
            required_keys = [
                'model',
                'scaler',
                'label_encoder',
                'waste_map'
            ]

            missing_keys = [key for key in required_keys if key not in self.model]

            if missing_keys:
                raise ValueError(f"Model is missing required components: {missing_keys}")

            # Validate specific components
            if not hasattr(self.model['model'], 'predict'):
                raise ValueError("XGBoost model is invalid")

            if not hasattr(self.model['scaler'], 'transform'):
                raise ValueError("Scaler model is invalid")

            if not hasattr(self.model['label_encoder'], 'classes_'):
                raise ValueError("Label encoder is invalid")

            if not isinstance(self.model['waste_map'], dict):
                raise ValueError("Waste map must be a dictionary")

            logger.info("[MODEL] ✓ Model validation passed!")
            logger.info(f"[MODEL] Model loaded from: {self.model_source}")
            logger.info(f"[MODEL] Components validated: {list(self.model.keys())}")
            logger.info(f"[MODEL] Waste classes: {list(self.model['label_encoder'].classes_)}")
            logger.info(f"[MODEL] Waste map: {self.model['waste_map']}")

            self.is_validated = True
            return True

        except Exception as e:
            logger.error(f"[MODEL] ✗ Model validation failed: {e}")
            self.is_validated = False
            raise

    def is_loaded(self) -> bool:
        """
        Check if model is loaded and validated

        Returns:
            bool: True if model is loaded and validated, False otherwise
        """
        return self.model is not None and self.is_validated

    def get_model(self) -> Optional[Dict[str, Any]]:
        """
        Get loaded model

        Returns:
            Dict containing model components or None if not loaded
        """
        return self.model

    def get_model_info(self) -> Dict[str, Any]:
        """
        Get information about the loaded model

        Returns:
            Dict containing model information
        """
        if not self.is_loaded():
            return {
                "loaded": False,
                "validated": False,
                "source": None,
                "error": "Model not loaded"
            }

        return {
            "loaded": True,
            "validated": self.is_validated,
            "source": self.model_source,
            "components": list(self.model.keys()) if self.model else [],
            "waste_classes": list(self.model['label_encoder'].classes_) if self.model else [],
            "n_classes": len(self.model['label_encoder'].classes_) if self.model else None,
            "threshold": self.model.get('threshold', None) if self.model else None,
            "waste_categories": list(set(self.model['waste_map'].values())) if self.model else []
        }


# Global model service instance
_model_service: Optional[ModelService] = None


def init_model_service(model_path: Optional[Path] = None, model_url: Optional[str] = None) -> ModelService:
    """
    Initialize global model service

    Args:
        model_path: Path to the local model file (fallback)
        model_url: URL to model in Supabase Storage (primary)

    Returns:
        ModelService instance
    """
    global _model_service
    _model_service = ModelService(model_path=model_path, model_url=model_url)
    return _model_service


def get_model_service() -> Optional[ModelService]:
    """
    Get global model service instance

    Returns:
        ModelService instance or None if not initialized
    """
    return _model_service
