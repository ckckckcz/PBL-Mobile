"""
Database client initialization for Supabase
"""

from supabase import create_client, Client
from .config import SUPABASE_URL, SUPABASE_KEY
import logging

logger = logging.getLogger(__name__)

# Inisialisasi Supabase client
supabase_client: Client = None

def init_supabase() -> Client:
    """
    Initialize Supabase client

    Returns:
        Client: Supabase client instance
    """
    global supabase_client

    try:
        supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
        logger.info("[STARTUP] ✓ Supabase client initialized successfully")
        return supabase_client
    except Exception as e:
        logger.error(f"[STARTUP] ✗ Failed to initialize Supabase client: {e}")
        return None

def get_supabase() -> Client:
    """
    Get Supabase client instance

    Returns:
        Client: Supabase client instance
    """
    return supabase_client
