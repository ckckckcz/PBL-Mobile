"""
Prediction service for waste classification
Dioptimalkan untuk matching Colab results
NO FAKE CONFIDENCE - Always use real probabilities from model
"""

from __future__ import annotations
import numpy as np
import pandas as pd
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

# Tips untuk setiap kategori sampah
WASTE_TIPS = {
    "ORGANIK": [
        {
            "title": "Pisahkan sampah organik dari anorganik",
            "color": "#10B981"
        },
        {
            "title": "Buat kompos dari sisa makanan",
            "color": "#4DB8AC"
        },
        {
            "title": "Gunakan untuk pakan ternak jika memungkinkan",
            "color": "#F59E0B"
        },
        {
            "title": "Hindari mencampur dengan plastik",
            "color": "#8B5CF6"
        },
        {
            "title": "Proses dalam waktu 24 jam untuk menghindari bau",
            "color": "#EF4444"
        }
    ],
    "ANORGANIK": [
        {
            "title": "Bersihkan sampah anorganik sebelum dibuang",
            "color": "#4DB8AC"
        },
        {
            "title": "Pisahkan plastik, kaca, dan logam",
            "color": "#F59E0B"
        },
        {
            "title": "Gunakan ulang wadah yang masih layak",
            "color": "#8B5CF6"
        },
        {
            "title": "Tekan plastik/kardus agar hemat ruang",
            "color": "#EF4444"
        },
        {
            "title": "Setorkan ke bank sampah terdekat",
            "color": "#10B981"
        }
    ]
}


class PredictionService:
    """
    Service for handling waste classification predictions
    """

    def __init__(self, model: Dict[str, Any]):
        """
        Initialize prediction service with loaded model

        Args:
            model: Dictionary containing model components
        """
        self.model_dict = model
        self.xgb_model = model.get('model')
        self.scaler = model.get('scaler')
        self.label_encoder = model.get('label_encoder')
        self.waste_map = model.get('waste_map', {})
        self.threshold = model.get('threshold', 0.6)

        # Get feature names from scaler if available
        self.feature_names = None
        if hasattr(self.scaler, 'feature_names_in_'):
            self.feature_names = self.scaler.feature_names_in_
            logger.info(f"[INIT] Scaler has {len(self.feature_names)} feature names")
        else:
            # Create default feature names for 38 features
            self.feature_names = [f"feature_{i}" for i in range(38)]
            logger.info(f"[INIT] Using default feature names (38 features)")

        logger.info(f"[INIT] XGBoost model: {type(self.xgb_model).__name__}")
        logger.info(f"[INIT] Scaler: {type(self.scaler).__name__}")
        logger.info(f"[INIT] Label encoder: {type(self.label_encoder).__name__}")
        logger.info(f"[INIT] Waste map: {self.waste_map}")
        logger.info(f"[INIT] Threshold: {self.threshold}")
        logger.info(f"[INIT] Label encoder classes: {list(self.label_encoder.classes_)}")

    def _format_probability_line(
        self,
        class_name: str,
        probability: float
    ) -> str:
        """
        Format single probability line to match Colab output exactly

        Format: "    ClassName              :  XX.XX% -> Sampah Category"

        Args:
            class_name: Original class name from label encoder
            probability: Probability value (0-1 scale)

        Returns:
            Formatted string line
        """
        # Format class name: replace underscores with spaces and title case
        formatted_name = class_name.replace('_', ' ').title()

        # Get category from waste_map
        category = self.waste_map.get(class_name, "ANORGANIK")

        # Calculate percentage
        prob_percentage = probability * 100

        formatted_line = (
            f"    {formatted_name:<20}: {prob_percentage:>6.2f}% -> "
            f"Sampah {category.title()}"
        )

        return formatted_line

    def _get_formatted_probabilities_string(
        self,
        probabilities: np.ndarray
    ) -> str:
        """
        Generate formatted probability string that matches Colab output exactly

        Args:
            probabilities: Probabilities array from model (shape: 1, n_classes)

        Returns:
            Formatted multi-line string with all class probabilities
        """
        lines = ["[PREDICT] ===== Class Probabilities ====="]

        # Iterate through all classes in order
        for idx, class_name in enumerate(self.label_encoder.classes_):
            if probabilities.shape[1] > idx:
                prob_value = float(probabilities[0][idx])
                line = self._format_probability_line(class_name, prob_value)
                lines.append(line)

        lines.append("[PREDICT] ✓ Probabilities displayed")

        return "\n".join(lines)

    def _log_probabilities(self, probabilities: np.ndarray) -> None:
        """
        Log probabilities in Colab-matching format

        Args:
            probabilities: Probabilities array from model
        """
        formatted_string = self._get_formatted_probabilities_string(probabilities)
        for line in formatted_string.split("\n"):
            logger.info(line)

    def predict(self, features: np.ndarray) -> Dict[str, Any]:
        """
        Perform prediction on preprocessed image features
        CRITICAL: Features harus sudah di-preprocess dengan image_preprocessor.py
        NO FAKE CONFIDENCE - Always uses real probabilities from model

        Args:
            features: Preprocessed image features (shape: 1, 38)

        Returns:
            Dict containing prediction results with REAL confidence from model

        Raises:
            ValueError: If model doesn't have predict_proba (required)
            Exception: If prediction fails
        """
        logger.info(f"[PREDICT] Input features shape: {features.shape}, dtype: {features.dtype}")
        logger.info(f"[PREDICT] Features range: min={features.min():.4f}, max={features.max():.4f}")

        # CRITICAL: Convert features to DataFrame with feature names for scaler
        if self.feature_names is not None:
            logger.info(f"[PREDICT] Converting to DataFrame with {len(self.feature_names)} feature names")
            features_df = pd.DataFrame(features, columns=self.feature_names)
            scaled_features = self.scaler.transform(features_df)
        else:
            # Fallback to numpy array if no feature names
            logger.warning("[PREDICT] No feature names available, using raw numpy array")
            scaled_features = self.scaler.transform(features)

        logger.info(f"[PREDICT] ✓ Scaled features shape: {scaled_features.shape}")
        logger.info(f"[PREDICT] Scaled range: min={scaled_features.min():.4f}, max={scaled_features.max():.4f}")

        # Perform XGBoost prediction
        logger.info("[PREDICT] XGBoost predicting...")
        prediction = self.xgb_model.predict(scaled_features)
        logger.info(f"[PREDICT] ✓ Raw prediction: {prediction}")

        # Get probabilities - MANDATORY, no fake confidence allowed
        if not hasattr(self.xgb_model, 'predict_proba'):
            error_msg = "Model doesn't have predict_proba method - cannot provide confidence"
            logger.error(f"[PREDICT] ✗ {error_msg}")
            raise ValueError(error_msg)

        probabilities = self.xgb_model.predict_proba(scaled_features)
        logger.info(f"[PREDICT] ✓ Probabilities shape: {probabilities.shape}")

        # Get REAL confidence from highest probability (NO FAKE CONFIDENCE)
        confidence = float(np.max(probabilities) * 100)
        logger.info(f"[PREDICT] ✓ Real confidence from model: {confidence:.2f}%")

        # Log detailed class probabilities in Colab format (DEBUG ONLY - NOT IN RESPONSE)
        self._log_probabilities(probabilities)

        # Decode prediction using label encoder, supporting string labels
        raw_pred = prediction[0]
        logger.info(f"[PREDICT] Raw prediction value: {raw_pred}")

        if isinstance(raw_pred, (np.integer, int, np.int32, np.int64)):
            pred_idx = int(raw_pred)
        else:
            waste_class_candidate = str(raw_pred)
            logger.info(f"[PREDICT] Treating raw prediction as class label: {waste_class_candidate}")
            try:
                pred_idx = int(self.label_encoder.transform([waste_class_candidate])[0])
            except ValueError:
                classes = list(self.label_encoder.classes_)
                if waste_class_candidate in classes:
                    pred_idx = classes.index(waste_class_candidate)
                else:
                    logger.warning("[PREDICT] Raw prediction not found in label encoder classes, using max probability index")
                    pred_idx = int(np.argmax(probabilities[0]))
        logger.info(f"[PREDICT] Prediction index: {pred_idx}")

        waste_class = self.label_encoder.inverse_transform([pred_idx])[0]
        logger.info(f"[PREDICT] ✓ Decoded waste class: {waste_class}")

        # Map to category using waste_map
        category = self.waste_map.get(waste_class, "ANORGANIK")
        logger.info(f"[PREDICT] Mapped category: {category}")

        # Remap B3 dan unknown ke ANORGANIK
        if category.upper() in ["B3", "UNKNOWN"]:
            logger.info(f"[PREDICT] ⚠️ Category {category} → Remapped to ANORGANIK")
            category = "ANORGANIK"

        logger.info(f"[PREDICT] ✓ Final category: {category}")

        # Format waste type name
        waste_type = waste_class.replace('_', ' ').title()
        logger.info(f"[PREDICT] ✓ Formatted waste type: {waste_type}")

        return {
            "waste_class": waste_class,
            "waste_type": waste_type,
            "category": category,
            "confidence": confidence,  # REAL confidence from model, not fake
            "probabilities": probabilities  # For internal use only, not sent to mobile
        }

    def format_response(
        self,
        prediction_result: Dict[str, Any],
        include_debug_info: bool = False
    ) -> Dict[str, Any]:
        """
        Format prediction results into lean API response for mobile
        NO modelInfo in production response - keep it lean for mobile apps

        Args:
            prediction_result: Prediction result from predict()
            include_debug_info: If True, include detailed model info (for debugging only)

        Returns:
            Formatted lean response dictionary for mobile
        """
        waste_type = prediction_result["waste_type"]
        category = prediction_result["category"]
        confidence = prediction_result["confidence"]

        # Get tips for the category
        tips = WASTE_TIPS.get(category, WASTE_TIPS["ANORGANIK"])

        # Lean response for mobile (no heavy metadata)
        response = {
            "success": True,
            "data": {
                "wasteType": waste_type,
                "category": f"Sampah {category.title()}",
                "confidence": round(confidence, 2),
                "tips": tips,
                "description": f"{waste_type} termasuk dalam kategori Sampah {category.title()}"
            }
        }

        # Include debug info only if explicitly requested (NOT for mobile/production)
        if include_debug_info:
            probabilities = prediction_result.get("probabilities")
            response["data"]["modelInfo"] = {
                "confidenceSource": "XGBoost.predict_proba() - real probability from model",
                "pipeline": {
                    "step_1": "Image → Resize to 16x16 and convert to grayscale",
                    "step_2": "Flatten and normalize to 0-1 (256 pixels)",
                    "step_3": "Extract 38 features by downsampling (every 6th pixel)",
                    "step_4": "MinMaxScaler.transform(38 features with feature names) → scaled features",
                    "step_5": "XGBoost.predict(scaled features) → class prediction",
                    "step_6": "LabelEncoder.inverse_transform() → waste class name",
                    "step_7": "waste_map lookup → category (ORGANIK/ANORGANIK)",
                    "step_8": "XGBoost.predict_proba() → REAL confidence (no fake values)"
                },
                "modelComponents": {
                    "xgb_model_type": type(self.xgb_model).__name__,
                    "scaler_type": type(self.scaler).__name__,
                    "label_encoder_type": type(self.label_encoder).__name__,
                    "n_classes": len(self.label_encoder.classes_),
                    "threshold": self.threshold
                },
                "probabilitiesPerClass": self._format_probabilities(probabilities) if probabilities is not None else {}
            }

        return response

    def _format_probabilities(self, probabilities: Optional[np.ndarray]) -> Dict[str, Any]:
        """
        Format probabilities for each class as structured data
        FOR DEBUG USE ONLY - Not sent to mobile apps

        Args:
            probabilities: Probabilities array from model

        Returns:
            Dictionary with probabilities per class
        """
        if probabilities is None:
            return {}

        result = {}

        for idx, class_name in enumerate(self.label_encoder.classes_):
            if probabilities.shape[1] > idx:
                prob_value = round(float(probabilities[0][idx]) * 100, 2)
                category = self.waste_map.get(class_name, "ANORGANIK")
                formatted_name = class_name.replace('_', ' ').title()
                result[formatted_name] = {
                    "probability": prob_value,
                    "category": f"Sampah {category.title()}"
                }

        return result


# Global prediction service instance
_prediction_service: Optional[PredictionService] = None


def init_prediction_service(model: Dict[str, Any]) -> PredictionService:
    """
    Initialize prediction service with loaded model

    Args:
        model: Model dictionary containing components

    Returns:
        PredictionService instance
    """
    global _prediction_service
    _prediction_service = PredictionService(model)
    logger.info("[SERVICE] ✓ Prediction service initialized")
    return _prediction_service


def get_prediction_service() -> Optional[PredictionService]:
    """
    Get prediction service instance

    Returns:
        PredictionService instance or None if not initialized
    """
    return _prediction_service
