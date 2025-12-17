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


def test_supabase_connection() -> dict:
    """
    Test Supabase connection and return status

    Returns:
        dict: {
            'success': bool,
            'message': str,
            'app_mode': str,
            'credentials_set': bool,
            'connection_ok': bool,
            'details': str
        }
    """
    result = {
        'success': False,
        'message': '',
        'app_mode': APP_MODE,
        'credentials_set': False,
        'connection_ok': False,
        'details': ''
    }

    # Check mode
    if APP_MODE.lower() == "demo":
        result['success'] = True
        result['message'] = "Running in DEMO mode - Supabase not required"
        result['details'] = "Demo mode active, database features disabled"
        logger.info("[DATABASE TEST] ✓ Demo mode - no connection test needed")
        return result

    # Check credentials
    if not SUPABASE_URL or not SUPABASE_KEY:
        result['message'] = "Supabase credentials not set in environment"
        result['details'] = f"SUPABASE_URL: {'✓' if SUPABASE_URL else '❌'}, SUPABASE_KEY: {'✓' if SUPABASE_KEY else '❌'}"
        logger.error(f"[DATABASE TEST] ❌ {result['message']}")
        logger.error(f"[DATABASE TEST] {result['details']}")
        return result

    result['credentials_set'] = True

    # Try to initialize and test connection
    try:
        logger.info("[DATABASE TEST] Testing Supabase connection...")

        # Get or initialize client
        client = get_supabase()
        if client is None:
            result['message'] = "Failed to initialize Supabase client"
            result['details'] = "Client initialization returned None"
            logger.error(f"[DATABASE TEST] ❌ {result['message']}")
            return result

        # Test actual connection by trying to list tables (minimal query)
        # This will fail if credentials are wrong
        try:
            # Try a simple query to verify connection
            # We use table('users').select('id').limit(0) to avoid fetching data
            test_query = client.table('users').select('id').limit(0).execute()
            result['connection_ok'] = True
            result['success'] = True
            result['message'] = "Supabase connection successful"
            result['details'] = "Successfully connected and authenticated to Supabase"
            logger.info("[DATABASE TEST] ✅ Connection test PASSED")
            logger.info("[DATABASE TEST] ✅ Credentials are valid and working")
        except Exception as query_error:
            error_msg = str(query_error)

            # Check for common auth errors
            if "JWT" in error_msg or "401" in error_msg or "Invalid API key" in error_msg:
                result['message'] = "Authentication failed - Invalid Supabase key"
                result['details'] = f"API key is invalid or expired: {error_msg}"
                logger.error(f"[DATABASE TEST] ❌ {result['message']}")
            elif "404" in error_msg or "not found" in error_msg.lower():
                result['message'] = "Connection failed - Invalid Supabase URL or table not found"
                result['details'] = f"URL might be incorrect or 'users' table doesn't exist: {error_msg}"
                logger.error(f"[DATABASE TEST] ❌ {result['message']}")
            else:
                result['message'] = "Connection test failed"
                result['details'] = f"Query error: {error_msg}"
                logger.error(f"[DATABASE TEST] ❌ {result['message']}: {error_msg}")

    except Exception as e:
        result['message'] = f"Connection test error: {str(e)}"
        result['details'] = f"Exception: {type(e).__name__} - {str(e)}"
        logger.error(f"[DATABASE TEST] ❌ {result['message']}")

    return result


def is_supabase_available() -> bool:
    """
    Check if Supabase is available

    Returns:
        bool: True if Supabase client is initialized and available
    """
    return _supabase_client is not None


def get_connection_status() -> dict:
    """
    Get current connection status without testing

    Returns:
        dict: Status information
    """
    return {
        'app_mode': APP_MODE,
        'credentials_set': bool(SUPABASE_URL and SUPABASE_KEY),
        'client_initialized': _supabase_client is not None,
        'supabase_url': SUPABASE_URL[:30] + "..." if SUPABASE_URL and len(SUPABASE_URL) > 30 else SUPABASE_URL,
    }


def reset_supabase():
    """
    Reset Supabase client (useful for testing)
    """
    global _supabase_client
    _supabase_client = None
    logger.info("[DATABASE] Supabase client reset")
