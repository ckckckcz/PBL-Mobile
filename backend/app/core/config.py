from dotenv import load_dotenv
import os

load_dotenv()  # load .env

# Application mode: 'demo' or 'production'
APP_MODE = os.getenv("APP_MODE", "demo")

# Supabase configuration (only used in production mode)
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
