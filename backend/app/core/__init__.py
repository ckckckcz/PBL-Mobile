"""
Core package for application configuration and shared utilities
"""

from .config import SUPABASE_URL, SUPABASE_KEY, APP_MODE
from .database import get_supabase, is_supabase_available, reset_supabase
from .logger import setup_logger, get_logger

__all__ = [
    "APP_MODE",
    "SUPABASE_URL",
    "SUPABASE_KEY",
    "get_supabase",
    "is_supabase_available",
    "reset_supabase",
    "setup_logger",
    "get_logger",
]
