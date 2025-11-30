"""
Entry point for Vercel deployment
This file imports the FastAPI app from the main application
"""

from app.main import app

# Vercel will look for 'app' variable in this file
# No need to run uvicorn here as Vercel handles that
