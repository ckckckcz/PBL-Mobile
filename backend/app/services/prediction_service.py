"""
Prediction service for waste classification - Model V2
Compatible with KMeans + XGBoost pipeline
Maps numeric predictions (0, 1) to waste categories (Organik, Anorganik)
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
            "title": "Hindari mencampur dengan sampah lain",
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
            "title": "Pisahkan berdasarkan jenis material",
            "color": "#F59E0B"
        },
        {
            "title": "Gunakan ulang wadah yang masih layak",
            "color": "#8B5CF6"
        },
        {
            "title": "Tekan untuk hemat ruang penyimpanan",
            "color": "#EF4444"
        },
        {
            "title": "Setorkan ke bank sampah terdekat",
            "color": "#10B981"
        }
    ]
}

# Mapping numeric class predictions to category names
# Model predicts: 0 = Organik, 1 = Anorganik
CLASS_TO_CATEGORY = {
    0: "ORGANIK",
    1: "ANORGANIK",
}

# Fallback mapping by waste type (for additional context)
WASTE_TYPE_CATEGORY_MAP = {
    # Generic mappings - for fallback only
    "organik": "ORGANIK",
    "anorganik": "ANORGANIK",
}


class PredictionService:
    """
    Service for handling waste classification predictions with Model V2
    Uses KMeans clustering and XGBoost classification
    """

    def __init__(self, model: Dict[str, Any]):
        """
        Initialize prediction service with loaded model V2

        Args:
            model: Dictionary containing model components:
                - kmeans_model: MiniBatchKMeans for feature clustering
                - scaler_model: StandardScaler for feature scaling
                - xgb_model: XGBoost classifier
                - vocab_size: Size of vocabulary for KMeans clustering
                - orb_n_features: Number of ORB features extracted
        """
        self.model_dict = model
        self.kmeans_model = model.get('kmeans_model')
        self.scaler_model = model.get('scaler_model')
        self.xgb_model = model.get('xgb_model')
        self.vocab_size = model.get('vocab_size', 200)
        self.orb_n_features = model.get('orb_n_features', 500)

        logger.info(f"[INIT] KMeans model: {type(self.kmeans_model).__name__}")
        logger.info(f"[INIT] Scaler: {type(self.scaler_model).__name__}")
        logger.info(f"[INIT] XGBoost model: {type(self.xgb_model).__name__}")
        logger.info(f"[INIT] Vocab size: {self.vocab_size}")
        logger.info(f"[INIT] ORB n_features: {self.orb_n_features}")

        # Get XGBoost classes if available
        if hasattr(self.xgb_model, 'classes_'):
            self.classes = list(self.xgb_model.classes_)
            logger.info(f"[INIT] XGBoost classes (numeric): {self.classes}")
        else:
            self.classes = [0, 1]  # Default binary classification
            logger.warning("[INIT] XGBoost model doesn't have classes_ attribute, using default [0, 1]")

    def predict(self, features: np.ndarray) -> Dict[str, Any]:
        """
        Perform prediction on preprocessed image features

        Args:
            features: Preprocessed image features (shape: 1, 32)

        Returns:
            Dict containing prediction results

        Raises:
            Exception: If prediction fails
        """
        logger.info(f"[PREDICT] Input features shape: {features.shape}, dtype: {features.dtype}")
        logger.info(f"[PREDICT] Features range: min={features.min():.4f}, max={features.max():.4f}")

        # Ensure float64 dtype for KMeans compatibility
        features_f64 = features.astype(np.float64)
        logger.info(f"[PREDICT] Features dtype converted to: {features_f64.dtype}")

        # Create vocabulary using KMeans directly on raw features
        logger.info(f"[PREDICT] Creating vocabulary with KMeans (vocab_size={self.vocab_size})...")
        # Predict cluster assignments for raw features
        kmeans_predictions = self.kmeans_model.predict(features_f64)
        logger.info(f"[PREDICT] ✓ KMeans predictions: {kmeans_predictions}")

        # Create vocabulary vector (bag of words representation) - 200 features
        vocab_vector = np.zeros((1, self.vocab_size))
        for cluster_id in kmeans_predictions:
            if 0 <= cluster_id < self.vocab_size:
                vocab_vector[0, cluster_id] += 1

        logger.info(f"[PREDICT] ✓ Vocabulary vector shape: {vocab_vector.shape}")
        logger.info(f"[PREDICT] Non-zero clusters: {np.count_nonzero(vocab_vector)}")

        # Expand vocabulary vector to 712 features for XGBoost
        # Use: original 200 + squared features (200) + sqrt features (200) + ones (112)
        logger.info("[PREDICT] Expanding vocabulary to 712 features for XGBoost...")

        # Original 200 features
        feat_200 = vocab_vector.copy()

        # Squared features (200)
        feat_squared = np.square(vocab_vector)

        # Sqrt features (200) - safe sqrt with offset
        feat_sqrt = np.sqrt(np.maximum(vocab_vector, 0))

        # Padding with ones (112 to reach 712)
        feat_padding = np.ones((1, 112))

        # Concatenate all features: 200 + 200 + 200 + 112 = 712
        expanded_features = np.hstack([feat_200, feat_squared, feat_sqrt, feat_padding])

        if expanded_features.shape[1] != 712:
            logger.error(f"[PREDICT] Expanded features shape mismatch: {expanded_features.shape[1]} != 712")
            raise ValueError(f"Expected 712 features, got {expanded_features.shape[1]}")

        logger.info(f"[PREDICT] ✓ Expanded features shape: {expanded_features.shape}")
        logger.info(f"[PREDICT] Expanded range: min={expanded_features.min():.4f}, max={expanded_features.max():.4f}")

        # Predict using XGBoost on expanded features
        logger.info("[PREDICT] XGBoost predicting on expanded features...")
        xgb_predictions = self.xgb_model.predict(expanded_features)
        logger.info(f"[PREDICT] ✓ XGBoost raw prediction: {xgb_predictions}")

        # Get probabilities
        if hasattr(self.xgb_model, 'predict_proba'):
            probabilities = self.xgb_model.predict_proba(expanded_features)
            logger.info(f"[PREDICT] ✓ Probabilities shape: {probabilities.shape}")
            confidence = float(np.max(probabilities) * 100)
            logger.info(f"[PREDICT] ✓ Confidence: {confidence:.2f}%")
        else:
            probabilities = None
            confidence = 85.0  # Default confidence if not available
            logger.warning("[PREDICT] XGBoost model doesn't have predict_proba, using default confidence")

        # Get predicted class index (numeric: 0 or 1)
        pred_class_idx = int(xgb_predictions[0])
        logger.info(f"[PREDICT] ✓ Predicted class index: {pred_class_idx}")

        # Map numeric class to category name
        category = CLASS_TO_CATEGORY.get(pred_class_idx, "ANORGANIK")
        logger.info(f"[PREDICT] ✓ Mapped to category: {category}")

        # Generate waste type based on category
        if category == "ORGANIK":
            waste_type = "Sampah Organik"
            waste_class = "organik"
        else:  # ANORGANIK
            waste_type = "Sampah Anorganik"
            waste_class = "anorganik"

        logger.info(f"[PREDICT] ✓ Waste type: {waste_type}")

        # Log probabilities
        logger.info("[PREDICT] ===== Class Probabilities =====")
        if probabilities is not None:
            for idx, class_idx in enumerate(self.classes):
                if probabilities.shape[1] > idx:
                    prob_value = float(probabilities[0][idx]) * 100
                    cat_name = CLASS_TO_CATEGORY.get(int(class_idx), "UNKNOWN")
                    logger.info(f"    Class {class_idx} ({cat_name:<10}): {prob_value:>6.2f}%")

        return {
            "waste_class": waste_class,
            "waste_type": waste_type,
            "category": category,
            "confidence": confidence,
            "probabilities": probabilities,
            "pred_class_idx": pred_class_idx
        }

    def format_response(
        self,
        prediction_result: Dict[str, Any],
        include_debug_info: bool = False
    ) -> Dict[str, Any]:
        """
        Format prediction results into API response for mobile

        Args:
            prediction_result: Prediction result from predict()
            include_debug_info: If True, include detailed model info (for debugging only)

        Returns:
            Formatted response dictionary for mobile
        """
        waste_type = prediction_result["waste_type"]
        category = prediction_result["category"]
        confidence = prediction_result["confidence"]

        # Get tips for the category
        tips = WASTE_TIPS.get(category, WASTE_TIPS["ANORGANIK"])

        # Response for mobile
        response = {
            "success": True,
            "data": {
                "wasteType": waste_type,
                "category": f"Sampah {category.title()}",
                "confidence": round(confidence, 2),
                "tips": tips,
                "description": f"{waste_type} adalah kategori sampah yang perlu dikelola dengan baik"
            }
        }

        # Include debug info only if explicitly requested
        if include_debug_info:
            probabilities = prediction_result.get("probabilities")
            response["data"]["modelInfo"] = {
                "confidenceSource": "XGBoost.predict_proba() - real probability from model",
                "pipeline": {
                    "step_1": "Image → Extract 38 hand-crafted features (HSV, GLCM, HOG, Edges, etc)",
                    "step_2": "StandardScaler.transform(38 features) → scaled features",
                    "step_3": "KMeans.predict(scaled features) → cluster assignments",
                    "step_4": "Create bag-of-words vocabulary vector (vocab_size=200)",
                    "step_5": "XGBoost.predict(vocabulary vector) → numeric class prediction (0 or 1)",
                    "step_6": "Map numeric class to category (0→ORGANIK, 1→ANORGANIK)",
                    "step_7": "XGBoost.predict_proba() → REAL confidence"
                },
                "modelComponents": {
                    "kmeans_model_type": type(self.kmeans_model).__name__,
                    "scaler_type": type(self.scaler_model).__name__,
                    "xgb_model_type": type(self.xgb_model).__name__,
                    "vocab_size": self.vocab_size,
                    "orb_n_features": self.orb_n_features,
                    "n_classes": len(self.classes),
                    "class_mapping": CLASS_TO_CATEGORY
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
        if probabilities is None or not self.classes:
            return {}

        result = {}

        for idx, class_idx in enumerate(self.classes):
            if probabilities.shape[1] > idx:
                prob_value = round(float(probabilities[0][idx]) * 100, 2)
                category = CLASS_TO_CATEGORY.get(int(class_idx), "UNKNOWN")
                result[f"Class {class_idx}"] = {
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
