"""
Image preprocessing service for Model V2
Extracts 32 features compatible with KMeans input
Pipeline: Extract 32 features -> KMeans clustering -> vocabulary vector (200 dims) -> Scaler -> XGBoost
"""

import cv2
import numpy as np
from PIL import Image
from typing import Union
import logging

logger = logging.getLogger(__name__)


class ImagePreprocessorV2:
    """
    Image preprocessor for Model V2
    Extracts 32 features for KMeans clustering
    """

    def __init__(self):
        """Initialize image preprocessor for model v2"""
        self.n_features = 32
        self.orb_n_features = 500
        self.orb = cv2.ORB_create(nfeatures=self.orb_n_features)
        logger.info(f"[INIT] ImagePreprocessorV2: {self.n_features} features for KMeans")

    def _load_image_as_array(self, image: Union[str, bytes, Image.Image, np.ndarray]) -> np.ndarray:
        """
        Load image from various input types

        Args:
            image: Image path, bytes, PIL Image, or numpy array

        Returns:
            np.ndarray: Image in BGR format (OpenCV)
        """
        if isinstance(image, np.ndarray):
            if len(image.shape) == 2:
                return cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
            elif image.shape[2] == 3:
                return cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
            return image

        if isinstance(image, Image.Image):
            img_array = np.array(image)
            if len(img_array.shape) == 2:
                return cv2.cvtColor(img_array, cv2.COLOR_GRAY2BGR)
            else:
                return cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)

        if isinstance(image, bytes):
            nparr = np.frombuffer(image, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img is None:
                raise ValueError("Failed to decode image from bytes")
            return img

        if isinstance(image, str):
            img = cv2.imread(image)
            if img is None:
                raise ValueError(f"Failed to load image from path: {image}")
            return img

        raise ValueError(f"Unsupported image type: {type(image)}")

    def _extract_color_histogram_features(self, img: np.ndarray) -> np.ndarray:
        """
        Extract 32 features from color histograms

        8 bins HSV histogram per channel (8*3=24) + 8 RGB features = 32

        Args:
            img: BGR image

        Returns:
            np.ndarray: Feature vector (32,)
        """
        try:
            features = []

            # HSV Histograms (8 bins each = 24 features)
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

            # H channel: 8 bins
            h_hist = cv2.calcHist([hsv], [0], None, [8], [0, 180])
            h_hist = cv2.normalize(h_hist, h_hist).flatten()
            features.extend(h_hist)

            # S channel: 8 bins
            s_hist = cv2.calcHist([hsv], [1], None, [8], [0, 256])
            s_hist = cv2.normalize(s_hist, s_hist).flatten()
            features.extend(s_hist)

            # V channel: 8 bins
            v_hist = cv2.calcHist([hsv], [2], None, [8], [0, 256])
            v_hist = cv2.normalize(v_hist, v_hist).flatten()
            features.extend(v_hist)

            # Additional 8 features: mean values of B, G, R channels + variance
            b_mean = np.mean(img[:, :, 0])
            g_mean = np.mean(img[:, :, 1])
            r_mean = np.mean(img[:, :, 2])

            b_var = np.var(img[:, :, 0])
            g_var = np.var(img[:, :, 1])
            r_var = np.var(img[:, :, 2])

            # Edge density
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            edges = cv2.Canny(gray, 50, 150)
            edge_density = np.sum(edges > 0) / edges.size

            features.extend([b_mean, g_mean, r_mean, b_var, g_var, r_var, edge_density, 0.0])

            features_array = np.array(features, dtype=np.float32)

            # Ensure exactly 32 features
            if len(features_array) < 32:
                padded = np.zeros(32, dtype=np.float32)
                padded[:len(features_array)] = features_array
                return padded
            else:
                return features_array[:32]

        except Exception as e:
            logger.error(f"[HIST] Error extracting histogram features: {e}")
            return np.zeros(32, dtype=np.float32)

    def extract_features(self, image: Union[str, bytes, Image.Image, np.ndarray]) -> np.ndarray:
        """
        Extract 32 features from image for KMeans

        Args:
            image: Image input (path, bytes, PIL Image, or numpy array)

        Returns:
            np.ndarray: Feature vector with shape (1, 32)
        """
        try:
            # Load image
            img = self._load_image_as_array(image)
            if img is None:
                raise ValueError("Image could not be loaded")

            logger.info(f"[EXTRACT] Input image shape: {img.shape}")

            # Resize to standard size (128x128)
            img = cv2.resize(img, (128, 128))

            # Extract 32 features
            features = self._extract_color_histogram_features(img)
            features = features.reshape(1, -1).astype(np.float32)

            if features.shape[1] != self.n_features:
                raise ValueError(
                    f"Expected {self.n_features} features, "
                    f"got {features.shape[1]}"
                )

            logger.info(
                f"[EXTRACT] Features shape: {features.shape}, "
                f"range: [{features.min():.4f}, {features.max():.4f}]"
            )

            return features

        except Exception as e:
            logger.error(f"[EXTRACT] Error extracting features: {e}")
            raise

    def preprocess(self, image: Union[str, bytes, Image.Image, np.ndarray]) -> np.ndarray:
        """
        Main preprocessing method

        Args:
            image: Image input

        Returns:
            np.ndarray: Feature vector (1, 32)
        """
        return self.extract_features(image)

    def preprocess_from_path(self, path: str) -> np.ndarray:
        """Extract features from image file path"""
        return self.preprocess(path)

    def preprocess_from_bytes(self, b: bytes) -> np.ndarray:
        """Extract features from image bytes"""
        return self.preprocess(b)


# Singleton instance
_image_preprocessor_v2 = None


def get_image_preprocessor_v2() -> ImagePreprocessorV2:
    """Get or create ImagePreprocessorV2 singleton"""
    global _image_preprocessor_v2
    if _image_preprocessor_v2 is None:
        _image_preprocessor_v2 = ImagePreprocessorV2()
        logger.info("[SERVICE] ImagePreprocessorV2 singleton created")
    return _image_preprocessor_v2
