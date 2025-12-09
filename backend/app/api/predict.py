"""
Prediction endpoint for waste classification
Strict validation and model readiness checks
NO predictions allowed before model is fully loaded and validated
"""

from fastapi import APIRouter, File, UploadFile, HTTPException
from PIL import Image
import io
import logging
import numpy as np
from typing import Dict, Any

from ..models.schemas import PredictionResponse
from ..services.model_service import get_model_service
from ..services.prediction_service import get_prediction_service
from ..services.image_service import get_image_preprocessor

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["Prediction"])

# Validation constants
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
MIN_IMAGE_SIZE = 16  # 16x16 pixels minimum
MAX_IMAGE_SIZE = 4096  # 4096x4096 pixels maximum
EXPECTED_FEATURE_SHAPE = (1, 38)  # Expected shape after preprocessing
EXPECTED_DTYPE = np.float32  # Expected dtype for features


def _check_model_readiness() -> None:
    """
    Check if model and prediction service are ready
    STRICT CHECK - Will raise HTTPException if not ready

    Raises:
        HTTPException: If model or prediction service is not ready
    """
    # Check model service
    model_service = get_model_service()
    if not model_service:
        logger.error("[PREDICT] Model service not initialized")
        raise HTTPException(
            status_code=503,
            detail="Model service not initialized - server starting up"
        )

    # Check if model is loaded
    if not model_service.is_loaded():
        logger.error("[PREDICT] Model not loaded or not validated")
        raise HTTPException(
            status_code=503,
            detail="Model not ready - please wait for model to load"
        )

    # Check prediction service
    prediction_service = get_prediction_service()
    if not prediction_service:
        logger.error("[PREDICT] Prediction service not initialized")
        raise HTTPException(
            status_code=503,
            detail="Prediction service not initialized - server starting up"
        )

    logger.debug("[PREDICT] ✓ Model and services are ready")


def _validate_features(features: np.ndarray) -> None:
    """
    Validate preprocessed features shape and dtype
    STRICT VALIDATION - Will raise HTTPException if invalid

    Args:
        features: Preprocessed features array

    Raises:
        HTTPException: If features are invalid
    """
    # Check shape
    if features.shape != EXPECTED_FEATURE_SHAPE:
        error_msg = f"Invalid feature shape: {features.shape}, expected {EXPECTED_FEATURE_SHAPE}"
        logger.error(f"[PREDICT] {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)

    # Check dtype
    if features.dtype != EXPECTED_DTYPE:
        error_msg = f"Invalid feature dtype: {features.dtype}, expected {EXPECTED_DTYPE}"
        logger.error(f"[PREDICT] {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)

    # Check for NaN or Inf values
    if np.isnan(features).any():
        error_msg = "Features contain NaN values"
        logger.error(f"[PREDICT] {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)

    if np.isinf(features).any():
        error_msg = "Features contain Inf values"
        logger.error(f"[PREDICT] {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)

    # Check value range (should be 0-1 after preprocessing)
    if features.min() < 0 or features.max() > 1:
        logger.warning(
            f"[PREDICT] Features outside expected range [0,1]: "
            f"min={features.min():.4f}, max={features.max():.4f}"
        )

    logger.debug("[PREDICT] ✓ Features validation passed")


def _format_lean_response(prediction_result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Format lean JSON response for mobile apps
    Remove heavy metadata, keep only essential data
    NO modelInfo, NO formatted_probabilities - lean response only
    """
    waste_type = prediction_result["waste_type"]
    category = prediction_result["category"]
    confidence = prediction_result["confidence"]

    # Simplified tips based on category
    if category.upper() == "ORGANIK":
        tips = [
            {"title": "Pisahkan dari sampah anorganik", "color": "#10B981"},
            {"title": "Buat kompos dari sisa makanan", "color": "#4DB8AC"},
            {"title": "Proses dalam 24 jam untuk menghindari bau", "color": "#F59E0B"}
        ]
    else:  # ANORGANIK
        tips = [
            {"title": "Bersihkan sebelum dibuang", "color": "#4DB8AC"},
            {"title": "Pisahkan plastik, kaca, dan logam", "color": "#F59E0B"},
            {"title": "Setorkan ke bank sampah terdekat", "color": "#10B981"}
        ]

    return {
        "success": True,
        "data": {
            "wasteType": waste_type,
            "category": f"Sampah {category.title()}",
            "confidence": round(confidence, 2),
            "tips": tips,
            "description": f"{waste_type} termasuk kategori Sampah {category.title()}"
        }
    }


@router.post("/predict", response_model=PredictionResponse)
async def predict_waste(file: UploadFile = File(...)):
    """
    Single endpoint untuk prediksi jenis sampah dari gambar
    STRICT VALIDATION - All inputs are validated before processing

    Validasi Input:
    - File type: image/* atau application/octet-stream
    - File size: maksimal 10MB
    - Image dimensions: 16x16 sampai 4096x4096 pixels
    - Feature shape: (1, 38)
    - Feature dtype: float32

    Model Readiness:
    - Model must be loaded and validated
    - Prediction service must be initialized

    Args:
        file: Image file untuk diprediksi (JPG, PNG, BMP, WebP)

    Returns:
        Lean JSON response dengan waste type, category, confidence, dan tips

    Raises:
        HTTPException:
            - 400: Invalid input (file type, size, dimensions)
            - 500: Processing error (preprocessing, prediction)
            - 503: Model not ready (not loaded or not validated)
    """
    logger.info(f"[PREDICT] New request: {file.filename}")

    # GUARD: Check model readiness FIRST - no processing if model not ready
    _check_model_readiness()

    # 1. Validate file type
    if not file.content_type:
        logger.error("[PREDICT] No content type provided")
        raise HTTPException(status_code=400, detail="File harus berupa gambar")

    allowed_types = {"image/jpeg", "image/png", "image/bmp", "image/webp", "application/octet-stream"}
    if file.content_type not in allowed_types:
        logger.error(f"[PREDICT] Invalid content type: {file.content_type}")
        raise HTTPException(
            status_code=400,
            detail=f"Format file tidak didukung. Allowed: {', '.join(allowed_types)}"
        )

    # 2. Read and validate file size
    try:
        contents = await file.read()

        if len(contents) == 0:
            logger.error("[PREDICT] Empty file")
            raise HTTPException(status_code=400, detail="File gambar kosong")

        if len(contents) > MAX_FILE_SIZE:
            logger.error(f"[PREDICT] File too large: {len(contents)} bytes")
            raise HTTPException(
                status_code=400,
                detail=f"File terlalu besar (maksimal {MAX_FILE_SIZE // (1024*1024)}MB)"
            )

        logger.info(f"[PREDICT] File size: {len(contents)} bytes ({len(contents) / 1024:.2f} KB)")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[PREDICT] Error reading file: {e}")
        raise HTTPException(status_code=500, detail="Error membaca file")

    # 3. Open and validate image
    try:
        image = Image.open(io.BytesIO(contents))

        # Validate image dimensions
        width, height = image.size
        if width < MIN_IMAGE_SIZE or height < MIN_IMAGE_SIZE:
            logger.error(f"[PREDICT] Image too small: {width}x{height}")
            raise HTTPException(
                status_code=400,
                detail=f"Gambar terlalu kecil (minimal {MIN_IMAGE_SIZE}x{MIN_IMAGE_SIZE} pixels)"
            )

        if width > MAX_IMAGE_SIZE or height > MAX_IMAGE_SIZE:
            logger.error(f"[PREDICT] Image too large: {width}x{height}")
            raise HTTPException(
                status_code=400,
                detail=f"Gambar terlalu besar (maksimal {MAX_IMAGE_SIZE}x{MAX_IMAGE_SIZE} pixels)"
            )

        logger.info(f"[PREDICT] Image validated: {width}x{height}, mode={image.mode}")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[PREDICT] Invalid image: {e}")
        raise HTTPException(status_code=400, detail="File bukan gambar yang valid")

    # 4. Preprocess image with strict validation
    try:
        logger.info("[PREDICT] Preprocessing image...")
        image_preprocessor = get_image_preprocessor()
        processed_features = image_preprocessor.preprocess(image)
        logger.info(f"[PREDICT] ✓ Preprocessed: shape={processed_features.shape}, dtype={processed_features.dtype}")

        # STRICT: Validate preprocessed features
        _validate_features(processed_features)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[PREDICT] Preprocessing failed: {e}")
        logger.exception(e)
        raise HTTPException(status_code=500, detail=f"Error preprocessing image: {str(e)}")

    # 5. Perform prediction (services already checked in _check_model_readiness)
    try:
        logger.info("[PREDICT] Running prediction...")
        prediction_service = get_prediction_service()
        prediction_result = prediction_service.predict(processed_features)

        logger.info(
            f"[PREDICT] ✓ Result: {prediction_result['waste_type']}, "
            f"Category: {prediction_result['category']}, "
            f"Confidence: {prediction_result['confidence']:.2f}%"
        )

    except ValueError as e:
        # ValueError from prediction service (e.g., missing predict_proba)
        logger.error(f"[PREDICT] Prediction validation error: {e}")
        raise HTTPException(status_code=500, detail=f"Model error: {str(e)}")
    except Exception as e:
        logger.error(f"[PREDICT] Prediction failed: {e}")
        logger.exception(e)
        raise HTTPException(status_code=500, detail=f"Error saat prediksi: {str(e)}")

    # 6. Format lean response for mobile (NO debug info)
    try:
        response = _format_lean_response(prediction_result)
        logger.info("[PREDICT] ✓ Prediction completed successfully")
        return response

    except Exception as e:
        logger.error(f"[PREDICT] Error formatting response: {e}")
        logger.exception(e)
        raise HTTPException(status_code=500, detail="Error formatting response")
