"""
Main application file for Pilar API
Optimized for Hugging Face deployment with APP_MODE support
- APP_MODE: 'demo' (HF/local) or 'production' (full features)
- Load model from local file only (backend/model/model_terbaru_v2.pkl)
- No Supabase initialization at startup (lazy init only)
- Sequential model loading: init_model_service() → load_model() → init_prediction_service()
- Auth/users routes disabled in demo mode
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import logging

# Core imports
from .core.logger import setup_logger
from .core.config import APP_MODE

# Service imports
from .services.model_service import init_model_service, get_model_service
from .services.prediction_service import init_prediction_service

# API Router imports
from .api import health, predict

# Setup logger
logger = setup_logger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Pilar API",
    description="API untuk klasifikasi sampah menggunakan XGBoost Hybrid Model",
    version="2.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    """
    Middleware untuk logging requests
    """
    logger.info(f"[REQUEST] {request.method} {request.url.path}")
    try:
        response = await call_next(request)
        logger.info(f"[RESPONSE] {request.method} {request.url.path} - Status: {response.status_code}")
        return response
    except Exception as e:
        logger.error(f"[ERROR] {request.method} {request.url.path} - {str(e)}")
        raise


@app.on_event("startup")
async def startup_event():
    """
    Startup handler - Load model from local file only
    Sequential loading: init_model_service() → load_model() → init_prediction_service()
    NO CONDITIONAL LOGIC that breaks the flow
    """
    logger.info("=" * 60)
    logger.info("[STARTUP] ===== Starting Pilar API =====")
    logger.info(f"[STARTUP] APP_MODE: {APP_MODE}")
    logger.info("=" * 60)

    # Define base directory - hardcoded for HF deployment
    BASE_DIR = Path(__file__).resolve().parent.parent

    logger.info(f"[STARTUP] Base directory: {BASE_DIR}")

    # STEP 1: Initialize model service (singleton pattern)
    logger.info("[STARTUP] Initializing model service (singleton)...")
    model_service = init_model_service(base_dir=BASE_DIR)
    logger.info("[STARTUP] ✓ Model service initialized")

    # STEP 3: Load model from local file (will raise exception if fails)
    logger.info("[STARTUP] Loading ML model from local file...")
    model = model_service.load_model()
    logger.info("[STARTUP] ✓ Model loaded successfully")

    # STEP 4: Get model info (validation already done in load_model)
    model_info = model_service.get_model_info()
    logger.info("[STARTUP] Model validation status:")
    logger.info(f"  - Loaded: {model_info.get('loaded', False)}")
    logger.info(f"  - Validated: {model_info.get('validated', False)}")
    logger.info(f"  - Source: {model_info.get('source', 'N/A')}")
    logger.info(f"  - Components: {model_info.get('components', [])}")
    logger.info(f"  - Number of classes: {model_info.get('n_classes', 'N/A')}")
    logger.info(f"  - Waste classes: {model_info.get('waste_classes', [])}")
    logger.info(f"  - Threshold: {model_info.get('threshold', 0.6)}")

    # STEP 5: Initialize prediction service (will use loaded model)
    logger.info("[STARTUP] Initializing prediction service...")
    init_prediction_service(model)
    logger.info("[STARTUP] ✓ Prediction service initialized")

    # STEP 6: Log mode-specific info
    logger.info("[STARTUP] Configuration:")
    logger.info(f"  - APP_MODE: {APP_MODE}")
    if APP_MODE.lower() == "demo":
        logger.info("  - Database: DISABLED (demo mode)")
        logger.info("  - Auth routes: DISABLED (demo mode)")
        logger.info("  - User routes: DISABLED (demo mode)")
    else:
        logger.info("  - Database: ENABLED (lazy init on request)")
        logger.info("  - Auth routes: ENABLED")
        logger.info("  - User routes: ENABLED")

    logger.info("=" * 60)
    logger.info("[STARTUP] ===== Pilar API Started Successfully =====")
    logger.info("=" * 60)


@app.on_event("shutdown")
async def shutdown_event():
    """
    Shutdown handler
    """
    logger.info("=" * 60)
    logger.info("[SHUTDOWN] ===== Shutting down Pilar API =====")
    logger.info("[SHUTDOWN] ✓ Shutdown complete")
    logger.info("=" * 60)


# Include core routers (always active)
app.include_router(health.router)
app.include_router(predict.router)

logger.info("[ROUTES] ✓ Core routers registered (health, predict)")

# Conditionally include auth/user routers based on APP_MODE
if APP_MODE.lower() == "production":
    try:
        # Import auth and user routers only in production mode
        from .api import auth, users

        app.include_router(auth.router)
        app.include_router(users.router)

        logger.info("[ROUTES] ✓ Production routers registered (auth, users)")
    except ImportError as e:
        logger.warning(f"[ROUTES] ⚠ Could not import production routers: {e}")
        logger.warning("[ROUTES] ⚠ Running without auth/users endpoints")
else:
    logger.info("[ROUTES] ⚠ Auth/users routers DISABLED (demo mode)")

logger.info(f"[ROUTES] ✓ Ready for deployment in {APP_MODE.upper()} mode")
