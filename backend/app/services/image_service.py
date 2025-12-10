"""
Image preprocessing service for waste classification model
Feature extraction EXACTLY sama dengan training notebook

38 Features breakdown:
- HSV Histogram: 24 features (8 H + 8 S + 8 V)
- GLCM Texture: 5 features (contrast, dissimilarity, homogeneity, energy, correlation)
- HOG: 2 features (mean, std)
- Edge Detection (Canny): 3 features (mean, std, edge ratio)
- Sharpness/Blur (Laplacian): 2 features (variance, mean absolute)
- Reflection/Highlight: 2 features (bright pixel ratio, std)
"""

import cv2
import numpy as np
from skimage.feature import hog
from skimage.feature import graycomatrix, graycoprops
from PIL import Image
import logging
import io
from typing import Union

logger = logging.getLogger(__name__)


class ImagePreprocessor:
    """
    Service for preprocessing images for XGBoost model
    Extract 38 hand-crafted features EXACTLY sama dengan notebook training
    """

    def __init__(self, target_size=(128, 128)):
        """
        Initialize image preprocessor

        Args:
            target_size: Target size for feature extraction (128x128 sesuai notebook)
        """
        self.target_size = target_size
        self.n_features = 38  # Model expects exactly 38 features
        logger.info(f"[INIT] ImagePreprocessor initialized with target_size={target_size}")

    def _load_image_as_array(self, image: Union[str, bytes, Image.Image, np.ndarray]) -> np.ndarray:
        """
        Load image from various input types and convert to OpenCV BGR format

        Args:
            image: Can be file path, bytes, PIL Image, or numpy array

        Returns:
            np.ndarray: Image in BGR format (OpenCV default)
        """
        if isinstance(image, np.ndarray):
            # Already numpy array
            if len(image.shape) == 2:
                # Grayscale, convert to BGR
                return cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
            elif image.shape[2] == 3:
                # Assume RGB from PIL, convert to BGR
                return cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
            return image

        if isinstance(image, Image.Image):
            # PIL Image - convert to numpy then BGR
            img_array = np.array(image)
            if len(img_array.shape) == 2:
                return cv2.cvtColor(img_array, cv2.COLOR_GRAY2BGR)
            else:
                return cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)

        if isinstance(image, bytes):
            # Bytes - decode to numpy array
            nparr = np.frombuffer(image, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img is None:
                raise ValueError("Failed to decode image from bytes")
            return img

        if isinstance(image, str):
            # File path
            img = cv2.imread(image)
            if img is None:
                raise ValueError(f"Failed to load image from path: {image}")
            return img

        raise ValueError(f"Unsupported image type: {type(image)}")

    def extract_features(self, image: Union[str, bytes, Image.Image, np.ndarray]) -> np.ndarray:
        """
        Extract 38 features from image EXACTLY sama dengan notebook

        Feature breakdown:
        1. HSV Histogram (24 features)
        2. GLCM Texture (5 features)
        3. HOG (2 features)
        4. Edge Detection - Canny (3 features)
        5. Sharpness/Blur - Laplacian (2 features)
        6. Reflection/Highlight (2 features)

        Args:
            image: Image input (path, bytes, PIL Image, or numpy array)

        Returns:
            np.ndarray: Feature vector with shape (1, 38)

        Raises:
            Exception: If feature extraction fails
        """
        try:
            # Load and validate image
            img = self._load_image_as_array(image)

            if img is None:
                raise ValueError("Image could not be loaded")

            logger.info(f"[EXTRACT] Input image shape: {img.shape}")

            # Resize to target size (128x128)
            img = cv2.resize(img, self.target_size)
            logger.info(f"[EXTRACT] ✓ Resized to {self.target_size}")

            # Convert to grayscale for some features
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

            features = []

            # === 1. HSV Histogram (24 features) ===
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

            # H channel histogram (8 bins)
            h_hist = cv2.calcHist([hsv], [0], None, [8], [0, 180])
            cv2.normalize(h_hist, h_hist)
            features.extend(h_hist.flatten())

            # S channel histogram (8 bins)
            s_hist = cv2.calcHist([hsv], [1], None, [8], [0, 256])
            cv2.normalize(s_hist, s_hist)
            features.extend(s_hist.flatten())

            # V channel histogram (8 bins)
            v_hist = cv2.calcHist([hsv], [2], None, [8], [0, 256])
            cv2.normalize(v_hist, v_hist)
            features.extend(v_hist.flatten())

            logger.info(f"[EXTRACT] ✓ HSV histogram: 24 features")

            # === 2. GLCM Texture (5 features) ===
            glcm = graycomatrix(
                gray,
                distances=[1],
                angles=[0],
                levels=256,
                symmetric=True,
                normed=True
            )

            features.append(graycoprops(glcm, 'contrast')[0, 0])
            features.append(graycoprops(glcm, 'dissimilarity')[0, 0])
            features.append(graycoprops(glcm, 'homogeneity')[0, 0])
            features.append(graycoprops(glcm, 'energy')[0, 0])
            features.append(graycoprops(glcm, 'correlation')[0, 0])

            logger.info(f"[EXTRACT] ✓ GLCM texture: 5 features")

            # === 3. HOG (2 features) ===
            hog_feats, _ = hog(
                gray,
                orientations=9,
                pixels_per_cell=(16, 16),
                cells_per_block=(2, 2),
                visualize=True,
                block_norm='L2-Hys'
            )

            features.append(np.mean(hog_feats))
            features.append(np.std(hog_feats))

            logger.info(f"[EXTRACT] ✓ HOG: 2 features")

            # === 4. Edge Detection - Canny (3 features) ===
            edges = cv2.Canny(gray, 50, 150)

            features.append(np.mean(edges))
            features.append(np.std(edges))
            features.append(np.sum(edges > 0) / edges.size)  # Edge ratio

            logger.info(f"[EXTRACT] ✓ Canny edges: 3 features")

            # === 5. Sharpness/Blur - Laplacian (2 features) ===
            lap = cv2.Laplacian(gray, cv2.CV_64F)

            features.append(np.var(lap))
            features.append(np.mean(np.abs(lap)))

            logger.info(f"[EXTRACT] ✓ Laplacian: 2 features")

            # === 6. Reflection/Highlight (2 features) ===
            _, bright_mask = cv2.threshold(gray, 220, 255, cv2.THRESH_BINARY)

            features.append(np.sum(bright_mask > 0) / bright_mask.size)  # Bright pixel ratio
            features.append(np.std(gray))  # Intensity std

            logger.info(f"[EXTRACT] ✓ Reflection: 2 features")

            # Convert to numpy array and reshape
            features_array = np.array(features, dtype=np.float32).reshape(1, -1)

            # Validate feature count
            if features_array.shape[1] != self.n_features:
                raise ValueError(
                    f"Expected {self.n_features} features, got {features_array.shape[1]}"
                )

            logger.info(
                f"[EXTRACT] ✓ Final features shape: {features_array.shape}, "
                f"dtype: {features_array.dtype}, "
                f"min: {features_array.min():.4f}, max: {features_array.max():.4f}"
            )

            return features_array

        except Exception as e:
            logger.error(f"[EXTRACT] ✗ Error extracting features: {str(e)}")
            logger.exception(e)
            raise

    def preprocess(self, image: Union[str, bytes, Image.Image, np.ndarray]) -> np.ndarray:
        """
        Main preprocessing method - extract 38 features

        Args:
            image: Image input (path, bytes, PIL Image, or numpy array)

        Returns:
            np.ndarray: Feature vector with shape (1, 38)
        """
        return self.extract_features(image)

    # Convenience methods
    def preprocess_from_path(self, path: str) -> np.ndarray:
        """Extract features from image file path"""
        return self.preprocess(path)

    def preprocess_from_bytes(self, b: bytes) -> np.ndarray:
        """Extract features from image bytes"""
        return self.preprocess(b)


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
        logger.info("[SERVICE] ✓ ImagePreprocessor singleton created")
    return _image_preprocessor
