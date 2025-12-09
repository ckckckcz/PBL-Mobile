"""
Database client initialization for Supabase
Lazy initialization - only when needed, not at startup
"""

from __future__ import annotations
from typing import TYPE_CHECKING, Optional
import logging

if TYPE_CHECKING:
    from supabase import Client

from .config import SUPABASE_URL, SUPABASE_KEY, APP_MODE

logger = logging.getLogger(__name__)

# Global Supabase client instance (lazy-initialized)
_supabase_client: Optional["Client"] = None


def get_supabase() -> Optional["Client"]:
    """
    Get Supabase client instance (lazy initialization)
    Only initializes when first called, not at startup

    In demo mode, returns None and logs warning
    In production mode, initializes Supabase client on first call

    Returns:
        Optional[Client]: Supabase client instance or None if demo mode or initialization failed
    """
    global _supabase_client

    # Check if we're in demo mode
    if APP_MODE.lower() == "demo":
        if _supabase_client is None:
            logger.warning("[DATABASE] Running in DEMO mode - Supabase not initialized")
        return None

    # If already initialized, return cached instance
    if _supabase_client is not None:
        return _supabase_client

    # Lazy initialization for production mode
    try:
        if not SUPABASE_URL or not SUPABASE_KEY:
            logger.error("[DATABASE] Supabase credentials not found in environment variables")
            return None

        logger.info("[DATABASE] Initializing Supabase client (lazy init)...")
        from supabase import create_client
        _supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
        logger.info("[DATABASE] ✓ Supabase client initialized successfully")
        return _supabase_client

    except ImportError as e:
        logger.error(f"[DATABASE] ✗ Supabase library not installed: {e}")
        return None
    except Exception as e:
        logger.error(f"[DATABASE] ✗ Failed to initialize Supabase client: {e}")
        return None


def is_supabase_available() -> bool:
    """
    Check if Supabase is available

    Returns:
        bool: True if Supabase client is initialized and available
    """
    return _supabase_client is not None


def reset_supabase():
    """
    Reset Supabase client (useful for testing)
    """
    global _supabase_client
    _supabase_client = None
    logger.info("[DATABASE] Supabase client reset")
