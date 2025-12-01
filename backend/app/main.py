"""
Main application file for Pilar API
Refactored version with clean architecture and separated concerns
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import logging
import os

# Core imports
from .core.logger import setup_logger
from .core.database import init_supabase

# Service imports
from .services.model_service import init_model_service, get_model_service
from .services.prediction_service import init_prediction_service

# API Router imports
from .api import health, predict, users
from .auth import router as auth_router

# Constants
from app.constants.waste_data import WASTE_TIPS, CATEGORY_MAPPING

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
    Inisialisasi database, load model dari Supabase, dan setup services
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

    # Get model URL from environment variable
    MODEL_URL = os.getenv(
        "MODEL_URL",
        "https://qmvxvnojbqkvdkewvdoi.supabase.co/storage/v1/object/public/Model/model_terbaru_v2.pkl"
    )

    # Local model path as fallback
    BASE_DIR = Path(__file__).resolve().parent.parent
    MODEL_PATH = BASE_DIR / "model" / "model_terbaru_v2.pkl"

    try:
        # Initialize model service with Supabase URL and local fallback
        logger.info("[STARTUP] Initializing model service...")
        logger.info(f"[STARTUP] Primary source: Supabase Storage")
        logger.info(f"[STARTUP] Fallback source: Local file ({MODEL_PATH})")

        model_service = init_model_service(model_path=MODEL_PATH, model_url=MODEL_URL)

        # Load model (will try Supabase first, then fallback to local)
        model = model_service.load_model()

        # Get model info for logging
        model_info = model_service.get_model_info()
        logger.info(f"[STARTUP] ✓ Model loaded successfully from: {model_info['source']}")
        logger.info(f"[STARTUP] Model validated: {model_info['validated']}")
        logger.info(f"[STARTUP] Waste classes: {model_info['waste_classes']}")
        logger.info(f"[STARTUP] Number of classes: {model_info.get('n_classes', 'N/A')}")
        logger.info(f"[STARTUP] Threshold: {model_info.get('threshold', 'N/A')}")
        logger.info(f"[STARTUP] Waste categories: {model_info.get('waste_categories', [])}")

        # Initialize prediction service with loaded model
        logger.info("[STARTUP] Initializing prediction service...")
        init_prediction_service(model)
        logger.info("[STARTUP] ✓ Prediction service initialized")

    except Exception as e:
        logger.error(f"[STARTUP] ✗ Failed to load model: {e}")
        logger.warning("[STARTUP] ⚠ API will run without prediction capability")
        import traceback
        logger.error(traceback.format_exc())

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

def get_waste_category(waste_type: str) -> dict:
    """
    Get waste category and tips for a given waste type
    
    Args:
        waste_type: The waste type string
        
    Returns:
        dict: Contains category and tips
    """
    # Normalize input
    normalized_type = waste_type.strip()
    
    # Get category from mapping
    category = CATEGORY_MAPPING.get(normalized_type, normalized_type)
    
    # Get tips for this category
    tips = WASTE_TIPS.get(category, [])
    
    return {
        "category": category,
        "tips": tips
    }
