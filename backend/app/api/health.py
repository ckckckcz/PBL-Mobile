"""
Health check endpoints
All endpoints include model_loaded and model_validated status
"""

from fastapi import APIRouter
from ..models.schemas import HealthCheckResponse, RootResponse, TestResponse
from ..services.model_service import get_model_service
from ..core.config import APP_MODE
import logging

logger = logging.getLogger(__name__)

router = APIRouter(tags=["Health"])


@router.get("/", response_model=RootResponse)
async def root():
    """
    Root endpoint - API information
    Includes model_loaded and model_validated status
    """
    model_service = get_model_service()
    model_loaded = model_service.is_loaded() if model_service else False
    model_validated = False

    # Get detailed model info
    model_info = {}
    if model_service:
        model_info = model_service.get_model_info()
        model_validated = model_info.get("validated", False)

    return {
        "message": "Pilar API is ready!",
        "app_mode": APP_MODE,
        "model_loaded": model_loaded,
        "model_validated": model_validated,
        "model_info": {
            "loaded": model_info.get("loaded", False),
            "validated": model_info.get("validated", False),
            "source": model_info.get("source", "unknown"),
            "n_classes": model_info.get("n_classes", 0)
        },
        "endpoints": {
            "predict": "/api/predict",
            "health": "/health",
            "test": "/api/test",
            "model_status": "/api/model/status"
        },
        "server": "FastAPI",
        "version": "2.0.0"
    }


@router.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """
    Health check endpoint
    Returns model_loaded and model_validated status
    """
    model_service = get_model_service()
    model_loaded = model_service.is_loaded() if model_service else False

    # Get model validation status
    model_validated = False
    if model_service:
        model_info = model_service.get_model_info()
        model_validated = model_info.get("validated", False)

    # Determine overall health status
    status = "healthy" if (model_loaded and model_validated) else "degraded"

    return {
        "status": status,
        "model_loaded": model_loaded,
        "model_validated": model_validated,
        "ready_for_predictions": model_loaded and model_validated
    }


@router.get("/api/test", response_model=TestResponse)
async def test_endpoint():
    """
    Test endpoint untuk memastikan API dapat diakses
    Includes model_loaded and model_validated status
    """
    logger.info("[TEST] Test endpoint called")

    model_service = get_model_service()
    model_loaded = model_service.is_loaded() if model_service else False
    model_validated = False

    if model_service:
        model_info = model_service.get_model_info()
        model_validated = model_info.get("validated", False)

    return {
        "success": True,
        "message": "API is working!",
        "app_mode": APP_MODE,
        "model_loaded": model_loaded,
        "model_validated": model_validated,
        "timestamp": "OK"
    }


@router.get("/api/model/status")
async def model_status():
    """
    Endpoint untuk mengecek status model secara detail
    Includes complete model_loaded and model_validated status
    """
    logger.info("[MODEL STATUS] Model status check requested")

    model_service = get_model_service()

    if not model_service:
        return {
            "success": False,
            "message": "Model service not initialized",
            "app_mode": APP_MODE,
            "data": {
                "model_loaded": False,
                "model_validated": False,
                "source": None,
                "error": "Model service not found",
                "ready_for_predictions": False
            }
        }

    model_info = model_service.get_model_info()
    model_loaded = model_info.get("loaded", False)
    model_validated = model_info.get("validated", False)
    ready_for_predictions = model_loaded and model_validated

    return {
        "success": ready_for_predictions,
        "message": "Model loaded and validated" if model_validated else "Model not loaded or validation failed",
        "app_mode": APP_MODE,
        "data": {
            "model_loaded": model_loaded,
            "model_validated": model_validated,
            "ready_for_predictions": ready_for_predictions,
            "source": model_info.get("source", "unknown"),
            "components": model_info.get("components", []),
            "waste_classes": model_info.get("waste_classes", []),
            "model_details": {
                "n_classes": model_info.get("n_classes"),
                "threshold": model_info.get("threshold"),
                "waste_categories": model_info.get("waste_categories", [])
            }
        }
    }
