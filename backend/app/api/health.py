"""
Health check endpoints
"""

from fastapi import APIRouter
from ..models.schemas import HealthCheckResponse, RootResponse, TestResponse
from ..services.model_service import get_model_service
import logging

logger = logging.getLogger(__name__)

router = APIRouter(tags=["Health"])


@router.get("/", response_model=RootResponse)
async def root():
    """
    Root endpoint - API information
    """
    model_service = get_model_service()
    model_loaded = model_service.is_loaded() if model_service else False

    # Get detailed model info
    model_info = {}
    if model_service:
        model_info = model_service.get_model_info()

    return {
        "message": "Pilar API is ready!",
        "model_loaded": model_loaded,
        "model_info": {
            "loaded": model_info.get("loaded", False),
            "validated": model_info.get("validated", False),
            "source": model_info.get("source", "unknown")
        },
        "endpoints": {
            "predict": "/api/predict",
            "health": "/health",
            "test": "/api/test",
            "model_status": "/api/model/status"
        },
        "server": "FastAPI",
        "version": "1.0.0"
    }


@router.get("/health", response_model=HealthCheckResponse)
async def health_check():
    """
    Health check endpoint
    """
    model_service = get_model_service()
    model_loaded = model_service.is_loaded() if model_service else False

    # Get model validation status
    model_validated = False
    if model_service:
        model_info = model_service.get_model_info()
        model_validated = model_info.get("validated", False)

    return {
        "status": "healthy",
        "model_loaded": model_loaded,
        "model_validated": model_validated
    }


@router.get("/api/test", response_model=TestResponse)
async def test_endpoint():
    """
    Test endpoint untuk memastikan API dapat diakses
    """
    logger.info("[TEST] Test endpoint called")

    model_service = get_model_service()
    model_loaded = model_service.is_loaded() if model_service else False

    return {
        "success": True,
        "message": "API is working!",
        "model_loaded": model_loaded,
        "timestamp": "OK"
    }


@router.get("/api/model/status")
async def model_status():
    """
    Endpoint untuk mengecek status model secara detail
    Termasuk apakah model sudah berhasil diload dari Supabase atau tidak
    """
    logger.info("[MODEL STATUS] Model status check requested")

    model_service = get_model_service()

    if not model_service:
        return {
            "success": False,
            "message": "Model service not initialized",
            "data": {
                "loaded": False,
                "validated": False,
                "source": None,
                "error": "Model service not found"
            }
        }

    model_info = model_service.get_model_info()

    return {
        "success": model_info.get("loaded", False) and model_info.get("validated", False),
        "message": "Model loaded and validated" if model_info.get("validated") else "Model not loaded or validation failed",
        "data": {
            "loaded": model_info.get("loaded", False),
            "validated": model_info.get("validated", False),
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
