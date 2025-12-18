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


import cv2
from PIL import Image

class PredictionService:
    """
    Service for handling waste classification predictions with Model V2
    Uses KMeans clustering (BOVW) + Color Histogram and XGBoost classification
    Total features: 712 (200 BOVW + 512 Color Hist)
    """

    def __init__(self, model: Dict[str, Any]):
        """
        Initialize prediction service with loaded model V2

        Args:
            model: Dictionary containing model components:
                - kmeans_model: MiniBatchKMeans for feature clustering
                - xgb_model: XGBoost classifier
                - vocab_size: Size of vocabulary for KMeans clustering (default 200)
        """
        self.model_dict = model
        self.kmeans_model = model.get('kmeans_model')
        self.xgb_model = model.get('xgb_model')
        self.vocab_size = model.get('vocab_size', 200)

        # ORB detector
        self.orb = cv2.ORB_create()

        logger.info(f"[INIT] KMeans model: {type(self.kmeans_model).__name__}")
        logger.info(f"[INIT] XGBoost model: {type(self.xgb_model).__name__}")
        logger.info(f"[INIT] Vocab size: {self.vocab_size}")

        # Get XGBoost classes if available
        if hasattr(self.xgb_model, 'classes_'):
            self.classes = list(self.xgb_model.classes_)
            logger.info(f"[INIT] XGBoost classes (numeric): {self.classes}")
        else:
            self.classes = [0, 1]  # Default binary classification
            logger.warning("[INIT] XGBoost model doesn't have classes_ attribute, using default [0, 1]")

    def extract_hybrid_features(self, image: Any) -> Optional[np.ndarray]:
        """
        Extract hybrid features (BOVW + Color Hist)
        Matches the pipeline: ORB -> Descriptors -> KMeans Predict -> Hist(200) + ColorHist(512)
        Total: 712 features

        Args:
            image: PIL Image or numpy array (BGR)
        """
        # Convert PIL to BGR if needed
        if isinstance(image, Image.Image):
            img_array = np.array(image)
            img = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
        elif isinstance(image, np.ndarray):
            img = image
        else:
            logger.error(f"[EXTRACT] Unsupported image type: {type(image)}")
            return None

        # 1. BOVW Features (200)
        try:
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            kp, des = self.orb.detectAndCompute(gray, None)

            if des is not None:
                # Predict visual words using loaded KMeans
                # Ensure des is float for KMeans predict if needed, though usually standard for ORB is uint8
                # But sklearn kmeans usually expects float. Let's check.
                # ORB descriptors are uint8. Sklearn KMeans.predict expects float.
                des_float = des.astype(np.float64) 
                visual_words = self.kmeans_model.predict(des_float)
                
                # Histogram of visual words
                hist_bovw, _ = np.histogram(visual_words, bins=np.arange(self.vocab_size + 1), density=True)
            else:
                hist_bovw = np.zeros(self.vocab_size)
        except Exception as e:
            logger.error(f"[EXTRACT] BOVW error: {e}")
            hist_bovw = np.zeros(self.vocab_size)

        # 2. Color Histogram (512)
        try:
            img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
            # 8 bins per channel: 8*8*8 = 512
            hist_color = cv2.calcHist([img_hsv], [0, 1, 2], None, [8, 8, 8], [0, 180, 0, 256, 0, 256])
            cv2.normalize(hist_color, hist_color, 0, 1, cv2.NORM_MINMAX)
            hist_color_flat = hist_color.flatten() # 512
        except Exception as e:
            logger.error(f"[EXTRACT] Color Hist error: {e}")
            hist_color_flat = np.zeros(512)

        # Combine
        combined_features = np.hstack([hist_bovw, hist_color_flat]) # 200 + 512 = 712
        
        # Reshape to (1, 712) for prediction
        return combined_features.reshape(1, -1)

    def predict(self, image: Any) -> Dict[str, Any]:
        """
        Perform prediction on image using hybrid features

        Args:
            image: PIL Image or numpy array
        """
        # Extract features
        features = self.extract_hybrid_features(image)
        
        if features is None:
            raise ValueError("Failed to extract features from image")

        logger.info(f"[PREDICT] Hybrid features shape: {features.shape}")
        
        if features.shape[1] != 712:
             # Basic fallback if dimensions mismatch (shouldn't happen with correct logic)
             logger.error(f"[PREDICT] unexpected feature shape {features.shape}")

        # Predict using XGBoost
        logger.info("[PREDICT] XGBoost predicting...")
        xgb_predictions = self.xgb_model.predict(features)
        
        # Get probabilities
        if hasattr(self.xgb_model, 'predict_proba'):
            probabilities = self.xgb_model.predict_proba(features)
            confidence = float(np.max(probabilities) * 100)
            logger.info(f"[PREDICT] ✓ Confidence: {confidence:.2f}%")
        else:
            probabilities = None
            confidence = 85.0
            logger.warning("[PREDICT] No predict_proba, using default confidence")

        # Get predicted class index
        pred_class_idx = int(xgb_predictions[0])
        
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
                "confidenceSource": "XGBoost.predict_proba()",
                "pipeline": "Hybrid: BOVW (ORB+KMeans) + Color Hist (HSV)",
                "features": "200 (BOVW) + 512 (HSV) = 712",
                "probabilitiesPerClass": self._format_probabilities(probabilities) if probabilities is not None else {}
            }

        return response

    def _format_probabilities(self, probabilities: Optional[np.ndarray]) -> Dict[str, Any]:
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
    global _prediction_service
    _prediction_service = PredictionService(model)
    logger.info("[SERVICE] ✓ Prediction service initialized")
    return _prediction_service


def get_prediction_service() -> Optional[PredictionService]:
    return _prediction_service
