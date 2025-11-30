"""
Prediction endpoints for waste classification
"""

from fastapi import APIRouter, File, UploadFile, HTTPException
from PIL import Image
import io
import logging
from typing import Dict, Any
from .. models.schemas import PredictionResponse, ErrorResponse
from ..services.model_service import get_model_service
from ..services.prediction_service import get_prediction_service
from ..services.image_service import get_image_preprocessor

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["Prediction"])


@router.post("/predict", response_model=PredictionResponse)
async def predict_waste(file: UploadFile = File(... )):
    """
    Endpoint untuk prediksi jenis sampah dari gambar

    Args:
        file: Image file untuk diprediksi

    Returns:
        PredictionResponse: Hasil prediksi dengan kategori, confidence, dan tips

    Raises:
        HTTPException: Jika terjadi error dalam proses prediksi
    """
    logger.info(f"[PREDICT] ===== NEW PREDICTION REQUEST =====")
    logger.info(f"[PREDICT] Received from: {file.filename}")
    logger.info(f"[PREDICT] Content-Type: {file.content_type}")

    # Check if model is loaded
    model_service = get_model_service()
    if not model_service or not model_service.is_loaded():
        logger.error("[PREDICT] ✗ Model is not loaded")
        raise HTTPException(
            status_code=500,
            detail="Model belum dimuat di server"
        )

    # Check if prediction service is available
    prediction_service = get_prediction_service()
    if not prediction_service:
        logger.error("[PREDICT] ✗ Prediction service is not initialized")
        raise HTTPException(
            status_code=500,
            detail="Prediction service belum diinisialisasi"
        )

    # Validate file type - accept image/* dan application/octet-stream
    if file.content_type:
        is_image = file.content_type.startswith("image/")
        is_octet_stream = file.content_type == "application/octet-stream"

        if not (is_image or is_octet_stream):
            logger.error(f"[PREDICT] ✗ Invalid content type: {file.content_type}")
            raise HTTPException(
                status_code=400,
                detail="File harus berupa gambar"
            )
    else:
        logger.error("[PREDICT] ✗ No content type provided")
        raise HTTPException(
            status_code=400,
            detail="File harus berupa gambar"
        )

    try:
        # Read file contents
        logger.info("[PREDICT] Reading file contents...")
        contents = await file.read()
        logger.info(f"[PREDICT] File size: {len(contents)} bytes")

        if len(contents) == 0:
            logger.error("[PREDICT] ✗ File is empty!")
            raise HTTPException(
                status_code=400,
                detail="File gambar kosong"
            )

        # Open image
        logger.info("[PREDICT] Opening image...")
        image = Image.open(io.BytesIO(contents))
        logger.info(f"[PREDICT] ✓ Image opened - Size: {image.size}, Mode: {image.mode}")

        # Preprocess image
        logger.info("[PREDICT] Preprocessing image...")
        image_preprocessor = get_image_preprocessor()
        processed_features = image_preprocessor.preprocess(image)
        logger.info(f"[PREDICT] ✓ Image preprocessed - Shape: {processed_features.shape}")

        # Perform prediction
        logger.info("[PREDICT] Running prediction...")
        prediction_result = prediction_service.predict(processed_features)

        # Format response
        response = prediction_service.format_response(prediction_result)

        logger.info(f"[PREDICT] ===== PREDICTION SUCCESSFUL =====")
        logger.info(
            f"[PREDICT] Class: {prediction_result['waste_type']}, "
            f"Category: {prediction_result['category']}, "
            f"Confidence: {prediction_result['confidence']:.2f}%"
        )

        return response

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[PREDICT] ===== PREDICTION FAILED =====")
        logger. error(f"[PREDICT] Error: {str(e)}")
        logger.exception(e)
        raise HTTPException(
            status_code=500,
            detail=f"Error saat prediksi: {str(e)}"
        )