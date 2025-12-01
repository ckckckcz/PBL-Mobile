"""
Image preprocessing service for waste classification model
Dioptimalkan untuk match hasil preprocessing di Colab
"""

import numpy as np
from PIL import Image
import logging
from typing import Tuple

logger = logging.getLogger(__name__)


class ImagePreprocessor:
    """
    Service for preprocessing images for XGBoost Hybrid model
    Preprocessing harus EXACTLY sama dengan Colab notebook
    """

    def __init__(self, target_size: Tuple[int, int] = (16, 16)):
        """
        Initialize image preprocessor

        Args:
            target_size: Target image size for resizing (default: 16x16 sesuai Colab)
        """
        self.target_size = target_size
        self.n_features = 38  # Model expects exactly 38 features

    def preprocess(self, image: Image. Image) -> np.ndarray:
        """
        Preprocess image EXACTLY seperti di Colab notebook

        Steps:
        1. Convert to RGB
        2. Resize to 16x16
        3. Convert to grayscale
        4. Flatten dan normalize to 0-1
        5.  Extract 38 features dengan downsampling

        Args:
            image: PIL Image object

        Returns:
            np.ndarray: Preprocessed image features with shape (1, 38)

        Raises:
            Exception: If preprocessing fails
        """
        try:
            logger.info(f"[PREPROCESS] Input image mode: {image.mode}, size: {image.size}")

            # Step 1: Convert ke RGB (Colab juga convert semua ke RGB)
            if image.mode != 'RGB':
                logger.info(f"[PREPROCESS] Converting from {image.mode} to RGB")
                image = image.convert('RGB')

            # Step 2: Resize ke 16x16 (EXACT sama dengan Colab)
            image_resized = image.resize(self.target_size, Image. Resampling.LANCZOS)
            logger.info(f"[PREPROCESS] ✓ Resized to {self.target_size}")

            # Convert to numpy array
            img_array = np.array(image_resized, dtype=np.uint8)
            logger.info(f"[PREPROCESS] Array shape: {img_array.shape}, dtype: {img_array.dtype}")

            # Step 3: Convert RGB to Grayscale menggunakan standard formula
            # R: 0.299, G: 0.587, B: 0.114 (ITU-R BT.601 standard)
            if len(img_array.shape) == 3 and img_array.shape[2] == 3:
                img_gray = (
                    0.299 * img_array[:, :, 0]. astype(np.float32) +
                    0.587 * img_array[:, :, 1].astype(np.float32) +
                    0.114 * img_array[:, :, 2].astype(np.float32)
                )
                img_gray = img_gray. astype(np.uint8)
                logger.info(f"[PREPROCESS] ✓ Converted to grayscale, shape: {img_gray.shape}")
            else:
                img_gray = img_array
                logger.warning(f"[PREPROCESS] Image already grayscale or unexpected shape")

            # Step 4: Flatten dan normalize to 0-1 range
            img_flat = img_gray.flatten(). astype(np.float32) / 255.0
            logger.info(f"[PREPROCESS] ✓ Flattened to {len(img_flat)} pixels, normalized to 0-1")

            # Step 5: Extract 38 features dari 256 pixels (16x16)
            # Method: downsampling dengan step = 6
            # 256 pixels / 6 ≈ 42.67, ambil first 38
            features_list = []
            for i in range(0, len(img_flat), 6):
                if len(features_list) < 38:
                    features_list.append(img_flat[i])

            features_38 = np.array(features_list, dtype=np. float32)
            logger.info(f"[PREPROCESS] Downsampled to {len(features_38)} features")

            # Pad jika kurang dari 38
            if len(features_38) < 38:
                features_38 = np.pad(
                    features_38,
                    (0, 38 - len(features_38)),
                    mode='constant',
                    constant_values=0
                )
                logger.info(f"[PREPROCESS] Padded to 38 features")

            # Reshape ke (1, 38) untuk model
            features_38 = features_38.reshape(1, -1)

            logger.info(
                f"[PREPROCESS] ✓ Final features shape: {features_38.shape}, "
                f"dtype: {features_38.dtype}, "
                f"min: {features_38.min():.4f}, max: {features_38.max():.4f}"
            )

            return features_38

        except Exception as e:
            logger.error(f"[PREPROCESS] ✗ Error preprocessing image: {str(e)}")
            logger.exception(e)
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
