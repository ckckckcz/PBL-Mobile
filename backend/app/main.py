"""
Main application file for Pilar API
Refactored version with clean architecture and separated concerns
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import logging

# Core imports
from .core.logger import setup_logger
from .core.database import init_supabase

# Service imports
from .services.model_service import init_model_service, get_model_service
from .services.prediction_service import init_prediction_service

# API Router imports
from .api import health, predict, users
from .auth import router as auth_router

# Setup logger
logger = setup_logger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Pilar API",
    description="API untuk klasifikasi sampah menggunakan XGBoost Hybrid Model",
    version="1.0.0"
)

# CORS middleware untuk koneksi dengan React Native
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Izinkan semua origin untuk development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*", "Content-Type", "Authorization"],
    expose_headers=["*"],
)


# Middleware untuk logging requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """
    Middleware untuk logging setiap request dan response
    """
    logger.info(f"[REQUEST] {request.method} {request.url.path}")
    try:
        response = await call_next(request)
        logger.info(
            f"[RESPONSE] {request.method} {request.url.path} - "
            f"Status: {response.status_code}"
        )
        return response
    except Exception as e:
        logger.error(f"[ERROR] {request.method} {request.url.path} - {str(e)}")
        raise


@app.on_event("startup")
async def startup_event():
    """
    Event handler yang dijalankan saat aplikasi startup
    Inisialisasi database, load model, dan setup services
    """
    logger.info("[STARTUP] ===== Starting Pilar API =====")

    # Initialize Supabase client
    logger.info("[STARTUP] Initializing Supabase client...")
    supabase = init_supabase()
    if supabase:
        logger.info("[STARTUP] ✓ Supabase initialized")
    else:
        logger.warning("[STARTUP] ⚠ Supabase initialization failed")

    # Initialize model service and load model
    logger.info("[STARTUP] Loading machine learning model...")
    BASE_DIR = Path(__file__).resolve().parent.parent
    MODEL_PATH = BASE_DIR / "model" / "model_v2.pkl"

    try:
        model_service = init_model_service(MODEL_PATH)
        model = model_service.load_model()
        logger.info("[STARTUP] ✓ Model loaded successfully")

        # Initialize prediction service with loaded model
        logger.info("[STARTUP] Initializing prediction service...")
        init_prediction_service(model)
        logger.info("[STARTUP] ✓ Prediction service initialized")

    except Exception as e:
        logger.error(f"[STARTUP] ✗ Failed to load model: {e}")
        logger.warning("[STARTUP] ⚠ API will run without prediction capability")

    logger.info("[STARTUP] ===== Pilar API Started Successfully =====")


@app.on_event("shutdown")
async def shutdown_event():
    """
    Event handler yang dijalankan saat aplikasi shutdown
    Cleanup resources jika diperlukan
    """
    logger.info("[SHUTDOWN] ===== Shutting down Pilar API =====")
    # Add cleanup code here if needed
    logger.info("[SHUTDOWN] ✓ Shutdown complete")


# Include routers
app.include_router(health.router)
app.include_router(predict.router)
app.include_router(users.router)
app.include_router(auth_router)

logger.info("[ROUTES] All routers registered successfully")
