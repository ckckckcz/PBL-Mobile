from dotenv import load_dotenv
import os
import logging
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BACKEND_DIR = Path(__file__).resolve().parent.parent.parent
ENV_FILE = BACKEND_DIR / ".env"

# Load .env file with explicit path
load_dotenv(dotenv_path=ENV_FILE)

# Log where we're looking for .env
logger.info(f"[CONFIG] Looking for .env at: {ENV_FILE}")
logger.info(f"[CONFIG] .env file exists: {ENV_FILE.exists()}")

# Application mode: 'demo' or 'production'
APP_MODE = os.getenv("APP_MODE", "demo")

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

logger.info("=" * 60)
logger.info("[CONFIG] Environment Variables Status:")
logger.info(f"[CONFIG] APP_MODE: {APP_MODE}")

if APP_MODE.lower() == "production":
    if SUPABASE_URL:
        masked_url = SUPABASE_URL.split("//")[0] + "//" + SUPABASE_URL.split("//")[1].split("/")[0] if "//" in SUPABASE_URL else "***"
        logger.info(f"[CONFIG] SUPABASE_URL: {masked_url}")
    else:
        logger.error("[CONFIG] SUPABASE_URL: ❌ NOT SET")

    if SUPABASE_KEY:
        masked_key = SUPABASE_KEY[:10] + "..." if len(SUPABASE_KEY) > 10 else "***"
        logger.info(f"[CONFIG] SUPABASE_KEY: {masked_key}")
    else:
        logger.error("[CONFIG] SUPABASE_KEY: ❌ NOT SET")

    if SUPABASE_URL and SUPABASE_KEY:
        logger.info("[CONFIG] ✅ All required credentials are set")
    else:
        logger.error("[CONFIG] ❌ Missing required credentials for production mode!")
else:
    logger.info("[CONFIG] Running in DEMO mode - Supabase credentials not required")

logger.info("=" * 60)
