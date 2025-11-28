"""
Core package for application configuration and shared utilities
"""

from .config import SUPABASE_URL, SUPABASE_KEY
from .database import init_supabase, get_supabase
from .logger import setup_logger, get_logger

__all__ = [
    "SUPABASE_URL",
    "SUPABASE_KEY",
    "init_supabase",
    "get_supabase",
    "setup_logger",
    "get_logger",
]
