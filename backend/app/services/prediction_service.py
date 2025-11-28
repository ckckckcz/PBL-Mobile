"""
Prediction service for waste classification
"""

import numpy as np
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
    ],
    "B3": [
        {
            "title": "Jangan buang sembarangan, berbahaya!",
            "color": "#EF4444"
        },
        {
            "title": "Simpan dalam wadah tertutup khusus",
            "color": "#F59E0B"
        },
        {
            "title": "Serahkan ke tempat pengolahan B3",
            "color": "#8B5CF6"
        },
        {
            "title": "Jauhkan dari jangkauan anak-anak",
            "color": "#EF4444"
        },
        {
            "title": "Gunakan label peringatan pada wadah",
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

        logger.info(f"[INIT] XGBoost model: {type(self.xgb_model).__name__}")
        logger.info(f"[INIT] Scaler: {type(self.scaler).__name__}")
        logger.info(f"[INIT] Label encoder: {type(self.label_encoder).__name__}")
        logger.info(f"[INIT] Waste map: {self.waste_map}")
        logger.info(f"[INIT] Threshold: {self.threshold}")

    def predict(self, features: np.ndarray) -> Dict[str, Any]:
        """
        Perform prediction on preprocessed image features

        Args:
            features: Preprocessed image features (shape: 1, 31)

        Returns:
            Dict containing prediction results with confidence and probabilities

        Raises:
            Exception: If prediction fails
        """
        try:
            logger.info(f"[PREDICT] Input features shape: {features.shape}")

            # Scale features using MinMaxScaler
            logger.info("[PREDICT] Scaling features with MinMaxScaler...")
            scaled_features = self.scaler.transform(features)
            logger.info(f"[PREDICT] Scaled features shape: {scaled_features.shape}")

            # Predict with XGBoost
            logger.info("[PREDICT] XGBoost predicting...")
            prediction = self.xgb_model.predict(scaled_features)
            logger.info(f"[PREDICT] Raw prediction: {prediction}")

            # Get probabilities
            probabilities = None
            confidence = 85.0  # Default confidence

            if hasattr(self.xgb_model, 'predict_proba'):
                probabilities = self.xgb_model.predict_proba(scaled_features)
                confidence = float(np.max(probabilities) * 100)
                logger.info(f"[PREDICT] Probabilities: {probabilities}")
                logger.info(f"[PREDICT] Max confidence: {confidence}%")
            else:
                logger.warning("[PREDICT] Model doesn't have predict_proba, using default confidence")

            # Decode prediction using label encoder
            pred_idx = int(prediction[0])
            waste_class = self.label_encoder.inverse_transform([pred_idx])[0]
            logger.info(f"[PREDICT] Decoded waste class: {waste_class}")

            # Map to category using waste_map
            category = self.waste_map.get(waste_class, "ANORGANIK")
            logger.info(f"[PREDICT] Category from waste_map: {category}")

            # Format waste type name (capitalize first letter of each word)
            waste_type = waste_class.replace('_', ' ').title()
            logger.info(f"[PREDICT] Formatted waste type: {waste_type}")

            return {
                "waste_class": waste_class,
                "waste_type": waste_type,
                "category": category,
                "confidence": confidence,
                "probabilities": probabilities
            }

        except Exception as e:
            logger.error(f"[PREDICT] Error during prediction: {e}")
            logger.exception(e)
            raise

    def format_response(
        self,
        prediction_result: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Format prediction results into API response structure

        Args:
            prediction_result: Prediction result from predict()

        Returns:
            Formatted response dictionary
        """
        waste_type = prediction_result["waste_type"]
        category = prediction_result["category"]
        confidence = prediction_result["confidence"]
        probabilities = prediction_result["probabilities"]

        # Get tips for the category
        tips = WASTE_TIPS.get(category, WASTE_TIPS["ANORGANIK"])

        response = {
            "success": True,
            "data": {
                "wasteType": waste_type,
                "category": f"Sampah {category.title()}",
                "confidence": round(confidence, 2),
                "tips": tips,
                "description": f"{waste_type} termasuk dalam kategori Sampah {category.title()}",
                "modelInfo": {
                    "confidenceSource": "XGBoost.predict_proba() - probability of predicted class",
                    "pipeline": {
                        "step_1": "Image → Resize to 16x16 and convert to grayscale",
                        "step_2": "Flatten and normalize to 0-1 (256 pixels)",
                        "step_3": "Extract 31 features by downsampling",
                        "step_4": "MinMaxScaler.transform(31 features) → scaled features",
                        "step_5": "XGBoost.predict(31 features) → class prediction",
                        "step_6": "LabelEncoder.inverse_transform() → waste class name",
                        "step_7": "waste_map lookup → category (ORGANIK/ANORGANIK/B3)",
                        "step_8": "XGBoost.predict_proba(31 features) → confidence"
                    },
                    "modelComponents": {
                        "xgb_model_type": type(self.xgb_model).__name__,
                        "scaler_type": type(self.scaler).__name__,
                        "label_encoder_type": type(self.label_encoder).__name__,
                        "n_classes": len(self.label_encoder.classes_),
                        "classes": list(self.label_encoder.classes_),
                        "waste_map": self.waste_map,
                        "threshold": self.threshold
                    },
                    "probabilitiesPerClass": self._format_probabilities(probabilities),
                }
            }
        }

        return response

    def _format_probabilities(self, probabilities: Optional[np.ndarray]) -> Dict[str, Any]:
        """
        Format probabilities for each class

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
    logger.info("[SERVICE] Prediction service initialized")
    return _prediction_service


def get_prediction_service() -> Optional[PredictionService]:
    """
    Get prediction service instance

    Returns:
        PredictionService instance or None if not initialized
    """
    return _prediction_service
