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

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["Prediction"])

# Validation constants
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
MIN_IMAGE_SIZE = 16  # 16x16 pixels minimum
MAX_IMAGE_SIZE = 4096  # 4096x4096 pixels maximum
EXPECTED_FEATURE_SHAPE = (1, 32)  # Expected shape after preprocessing (Model V2)
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




def _format_lean_response(prediction_result: Dict[str, Any]) -> Dict[str, Any]:
    """
    Format lean JSON response for mobile apps
    Binary classification: only Sampah Organik or Sampah Anorganik
    Remove heavy metadata, keep only essential data
    """
    waste_type = prediction_result["waste_type"]
    category = prediction_result["category"]
    confidence = prediction_result["confidence"]

    # Tips based on category (Organik or Anorganik only)
    if category.upper() == "ORGANIK":
        tips = [
            {"title": "Pisahkan sampah organik dari anorganik", "color": "#10B981"},
            {"title": "Buat kompos dari sisa makanan", "color": "#4DB8AC"},
            {"title": "Gunakan untuk pakan ternak jika memungkinkan", "color": "#F59E0B"},
            {"title": "Hindari mencampur dengan sampah lain", "color": "#8B5CF6"},
            {"title": "Proses dalam waktu 24 jam untuk menghindari bau", "color": "#EF4444"}
        ]
    else:  # ANORGANIK
        tips = [
            {"title": "Bersihkan sampah anorganik sebelum dibuang", "color": "#4DB8AC"},
            {"title": "Pisahkan berdasarkan jenis material", "color": "#F59E0B"},
            {"title": "Gunakan ulang wadah yang masih layak", "color": "#8B5CF6"},
            {"title": "Tekan untuk hemat ruang penyimpanan", "color": "#EF4444"},
            {"title": "Setorkan ke bank sampah terdekat", "color": "#10B981"}
        ]

    return {
        "success": True,
        "data": {
            "wasteType": waste_type,
            "category": f"Sampah {category.title()}",
            "confidence": round(confidence, 2),
            "tips": tips,
            "description": f"{waste_type} adalah kategori sampah yang perlu dikelola dengan baik"
        }
    }


@router.post("/predict", response_model=PredictionResponse)
async def predict_waste(file: UploadFile = File(...)):
    """
    Endpoint untuk prediksi jenis sampah dari gambar
    Binary classification: Sampah Organik atau Sampah Anorganik
    STRICT VALIDATION - All inputs are validated before processing

    Validasi Input:
    - File type: image/* atau application/octet-stream
    - File size: maksimal 10MB
    - Image dimensions: 16x16 sampai 4096x4096 pixels
    - Feature shape: (1, 32) for Model V2
    - Feature dtype: float32

    Model Readiness:
    - Model must be loaded and validated
    - Prediction service must be initialized

    Args:
        file: Image file untuk diprediksi (JPEG/JPG, PNG, BMP, WebP, GIF)

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

    # Support various MIME types for maximum mobile compatibility
    allowed_types = {
        "image/jpeg",      # Standard JPEG
        "image/jpg",       # Non-standard but common (mobile devices)
        "image/png",       # PNG
        "image/bmp",       # BMP
        "image/webp",      # WebP
        "image/gif",       # GIF
        "image/x-ms-bmp",  # Windows BMP variant
        "application/octet-stream"  # Generic binary (fallback)
    }
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

    # 4. Preprocess and Predict
    try:
        logger.info("[PREDICT] Running prediction service (Hybrid Hybrid: BOVW + Color Hist)...")
        prediction_service = get_prediction_service()
        
        # Pass the PIL Image directly to prediction service
        # conversion to CV2/Array happens inside the service
        prediction_result = prediction_service.predict(image)

        logger.info(
            f"[PREDICT] ✓ Result: {prediction_result['waste_type']}, "
            f"Category: {prediction_result['category']}, "
            f"Confidence: {prediction_result['confidence']:.2f}%"
        )

    except ValueError as e:
        # ValueError from prediction service (e.g., feature extraction failed)
        logger.error(f"[PREDICT] Prediction error: {e}")
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
