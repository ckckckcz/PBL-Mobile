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

    return {
        "message": "Pilar API is ready!",
        "model_loaded": model_loaded,
        "endpoints": {
            "predict": "/api/predict",
            "health": "/health",
            "test": "/api/test"
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

    return {
        "status": "healthy",
        "model_loaded": model_loaded
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
