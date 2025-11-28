"""
Image preprocessing service for waste classification model
"""

import numpy as np
from PIL import Image
from typing import Tuple
import logging

logger = logging.getLogger(__name__)


class ImagePreprocessor:
    """
    Service for preprocessing images for XGBoost Hybrid model
    """

    def __init__(self, target_size: Tuple[int, int] = (16, 16)):
        """
        Initialize image preprocessor

        Args:
            target_size: Target image size for resizing (width, height)
        """
        self.target_size = target_size

    def preprocess(self, image: Image.Image) -> np.ndarray:
        """
        Preprocess image untuk prediksi model XGBoost Hybrid
        Extract 31 features yang sesuai dengan model training

        Args:
            image: PIL Image object

        Returns:
            np.ndarray: Preprocessed image features with shape (1, 31)

        Raises:
            Exception: If preprocessing fails
        """
        try:
            # Convert to RGB jika diperlukan
            if image.mode != 'RGB':
                image = image.convert('RGB')
                logger.info(f"[PREPROCESS] Converted image from {image.mode} to RGB")

            # Resize image ke target size untuk extract features
            image = image.resize(self.target_size, Image.Resampling.LANCZOS)
            logger.info(f"[PREPROCESS] Resized image to {self.target_size}")

            # Convert to numpy array
            img_array = np.array(image, dtype=np.uint8)

            # Convert RGB to grayscale
            if len(img_array.shape) == 3:
                img_gray = (
                    0.299 * img_array[:, :, 0].astype(np.float32) +
                    0.587 * img_array[:, :, 1].astype(np.float32) +
                    0.114 * img_array[:, :, 2].astype(np.float32)
                )
                img_gray = img_gray.astype(np.uint8)
            else:
                img_gray = img_array

            # Flatten image and normalize to 0-1
            img_flat = img_gray.flatten().astype(np.float32) / 255.0

            # Reduce to 31 features by taking every 8th element (skip last one)
            # (256 pixels / 8 = 32, then take first 31)
            features_31 = img_flat[::8][:31]

            # Ensure exactly 31 features
            if len(features_31) > 31:
                features_31 = features_31[:31]
            elif len(features_31) < 31:
                features_31 = np.pad(
                    features_31,
                    (0, 31 - len(features_31)),
                    mode='constant'
                )

            # Reshape untuk model: (1, 31)
            features_31 = features_31.reshape(1, -1)

            logger.info(
                f"[PREPROCESS] Features shape: {features_31.shape}, "
                f"n_features: {features_31.shape[1]}"
            )

            return features_31

        except Exception as e:
            logger.error(f"[PREPROCESS] Error preprocessing image: {e}")
            raise


# Singleton instance
_image_preprocessor = None


def get_image_preprocessor() -> ImagePreprocessor:
    """
    Get or create ImagePreprocessor singleton instance

    Returns:
        ImagePreprocessor: Image preprocessor instance
    """
    global _image_preprocessor
    if _image_preprocessor is None:
        _image_preprocessor = ImagePreprocessor()
    return _image_preprocessor
