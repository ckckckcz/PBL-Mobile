"""
Logging configuration for the application
Supports different log levels for demo vs production mode
"""

import logging
import sys
import os
from typing import Optional

def setup_logger(name: Optional[str] = None, level: Optional[str] = None) -> logging.Logger:
    """
    Setup logger with consistent formatting
    Auto-detects environment (demo vs production)

    Args:
        name: Logger name (default: root logger)
        level: Logging level as string (DEBUG, INFO, WARNING, ERROR)
               If None, auto-detects based on APP_MODE

    Returns:
        logging.Logger: Configured logger instance
    """
    logger = logging.getLogger(name)

    # Auto-detect log level based on APP_MODE
    if level is None:
        app_mode = os.getenv("APP_MODE", "demo").lower()
        if app_mode == "production":
            level = "WARNING"  # Less verbose for production
        else:
            level = "INFO"  # More verbose for demo/development

    # Convert string level to logging constant
    numeric_level = getattr(logging, level.upper(), logging.INFO)
    logger.setLevel(numeric_level)

    # Avoid adding duplicate handlers
    if not logger.handlers:
        # Create console handler
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(numeric_level)

        # Create formatter - different formats for different modes
        app_mode = os.getenv("APP_MODE", "demo").lower()
        if app_mode == "production":
            # Simpler format for production
            formatter = logging.Formatter(
                '[%(levelname)s] %(name)s - %(message)s'
            )
        else:
            # Detailed format for demo/debug
            formatter = logging.Formatter(
                '[%(asctime)s] %(levelname)s - %(name)s - %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S'
            )

        handler.setFormatter(formatter)
        logger.addHandler(handler)

    return logger

def get_logger(name: str, level: Optional[str] = None) -> logging.Logger:
    """
    Get logger instance by name with optional level override

    Args:
        name: Logger name
        level: Optional log level override (DEBUG, INFO, WARNING, ERROR)

    Returns:
        logging.Logger: Logger instance
    """
    return setup_logger(name, level)

# Setup basic logging configuration based on APP_MODE
app_mode = os.getenv("APP_MODE", "demo").lower()
default_level = logging.WARNING if app_mode == "production" else logging.INFO

logging.basicConfig(
    level=default_level,
    format='[%(asctime)s] %(levelname)s - %(name)s - %(message)s' if app_mode != "production" else '[%(levelname)s] %(name)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
