from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr, Field
from supabase import create_client
from .config import SUPABASE_URL, SUPABASE_KEY
import bcrypt
import jwt
from datetime import datetime, timedelta
from typing import Optional
import logging

# Setup logging
logger = logging.getLogger(__name__)

# Initialize router
router = APIRouter(prefix="/api/auth", tags=["Authentication"])

# Initialize Supabase client
try:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    logger.info("[AUTH] ✓ Supabase client initialized")
except Exception as e:
    logger.error(f"[AUTH] ✗ Failed to initialize Supabase: {e}")
    supabase = None

# Security
security = HTTPBearer()

# JWT Configuration
SECRET_KEY = "your-secret-key-change-this-in-production"  # TODO: Move to .env
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # 7 days

# ================================================================================
# PYDANTIC MODELS
# ================================================================================

class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    full_name: str = Field(..., min_length=2, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)

class LoginResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None
    token: Optional[str] = None

class UserResponse(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    avatar_url: Optional[str]
    is_verified: bool
    created_at: str

# ================================================================================
# HELPER FUNCTIONS
# ================================================================================

def hash_password(password: str) -> str:
    """Hash password menggunakan bcrypt"""
    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password dengan hash"""
    try:
        return bcrypt.checkpw(
            plain_password.encode('utf-8'),
            hashed_password.encode('utf-8')
        )
    except Exception as e:
        logger.error(f"Error verifying password: {e}")
        return False

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_token(token: str) -> dict:
    """Decode JWT token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired"
        )
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Dependency untuk mendapatkan user dari token"""
    token = credentials.credentials
    payload = decode_token(token)
    user_id = payload.get("user_id")

    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials"
        )

    return user_id

# ================================================================================
# AUTH ENDPOINTS
# ================================================================================

@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest):
    """
    Login endpoint

    - **email**: Email user yang sudah terdaftar
    - **password**: Password user (minimal 6 karakter)

    Returns:
    - User data dan JWT token jika berhasil
    """
    logger.info(f"[LOGIN] Login attempt for email: {request.email}")

    try:
        # Query user dari Supabase
        response = supabase.table('users').select('*').eq('email', request.email).execute()

        if not response.data or len(response.data) == 0:
            logger.warning(f"[LOGIN] User not found: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email atau password salah"
            )

        user = response.data[0]

        # Check if user is active
        if not user.get('is_active', True):
            logger.warning(f"[LOGIN] Inactive user tried to login: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Akun Anda tidak aktif. Silakan hubungi admin."
            )

        # Verify password
        if not verify_password(request.password, user['password_hash']):
            logger.warning(f"[LOGIN] Invalid password for: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email atau password salah"
            )

        # Update last_login
        supabase.table('users').update({
            'last_login': datetime.utcnow().isoformat()
        }).eq('id', user['id']).execute()

        # Create access token
        access_token = create_access_token(
            data={
                "user_id": user['id'],
                "email": user['email']
            }
        )

        # Prepare user data (exclude password_hash)
        user_data = {
            "id": user['id'],
            "email": user['email'],
            "full_name": user['full_name'],
            "phone": user.get('phone'),
            "avatar_url": user.get('avatar_url'),
            "is_verified": user.get('is_verified', False),
            "created_at": user['created_at']
        }

        logger.info(f"[LOGIN] ✓ Login successful for: {request.email}")

        return LoginResponse(
            success=True,
            message="Login berhasil",
            data=user_data,
            token=access_token
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[LOGIN] Error during login: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan pada server. Silakan coba lagi."
        )

@router.post("/register", response_model=LoginResponse)
async def register(request: RegisterRequest):
    """
    Register endpoint

    - **email**: Email user (harus unique)
    - **password**: Password user (minimal 6 karakter)
    - **full_name**: Nama lengkap user
    - **phone**: Nomor telepon (opsional)

    Returns:
    - User data dan JWT token jika berhasil
    """
    logger.info(f"[REGISTER] Registration attempt for email: {request.email}")

    try:
        # Check if email already exists
        existing_user = supabase.table('users').select('email').eq('email', request.email).execute()

        if existing_user.data and len(existing_user.data) > 0:
            logger.warning(f"[REGISTER] Email already exists: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email sudah terdaftar. Silakan gunakan email lain atau login."
            )

        # Hash password
        password_hash = hash_password(request.password)

        # Insert new user
        new_user_data = {
            "email": request.email,
            "password_hash": password_hash,
            "full_name": request.full_name,
            "phone": request.phone,
            "is_active": True,
            "is_verified": False
        }

        response = supabase.table('users').insert(new_user_data).execute()

        if not response.data or len(response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Gagal membuat akun. Silakan coba lagi."
            )

        user = response.data[0]

        # Create access token
        access_token = create_access_token(
            data={
                "user_id": user['id'],
                "email": user['email']
            }
        )

        # Prepare user data
        user_data = {
            "id": user['id'],
            "email": user['email'],
            "full_name": user['full_name'],
            "phone": user.get('phone'),
            "avatar_url": user.get('avatar_url'),
            "is_verified": user.get('is_verified', False),
            "created_at": user['created_at']
        }

        logger.info(f"[REGISTER] ✓ Registration successful for: {request.email}")

        return LoginResponse(
            success=True,
            message="Registrasi berhasil. Selamat datang!",
            data=user_data,
            token=access_token
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[REGISTER] Error during registration: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan pada server. Silakan coba lagi."
        )

@router.get("/me")
async def get_current_user_data(user_id: str = Depends(get_current_user)):
    """
    Get current user data from token

    Headers:
    - **Authorization**: Bearer {token}

    Returns:
    - Current user data
    """
    logger.info(f"[GET_ME] Fetching user data for: {user_id}")

    try:
        response = supabase.table('users').select('*').eq('id', user_id).execute()

        if not response.data or len(response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User tidak ditemukan"
            )

        user = response.data[0]

        # Prepare user data (exclude password_hash)
        user_data = {
            "id": user['id'],
            "email": user['email'],
            "full_name": user['full_name'],
            "phone": user.get('phone'),
            "avatar_url": user.get('avatar_url'),
            "is_verified": user.get('is_verified', False),
            "created_at": user['created_at']
        }

        return {
            "success": True,
            "data": user_data
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[GET_ME] Error fetching user data: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan pada server"
        )

@router.post("/logout")
async def logout(user_id: str = Depends(get_current_user)):
    """
    Logout endpoint (untuk consistency, token handling di client side)
    """
    logger.info(f"[LOGOUT] User logged out: {user_id}")
    return {
        "success": True,
        "message": "Logout berhasil"
    }

@router.get("/test")
async def test_auth():
    """Test endpoint untuk memastikan auth module berfungsi"""
    return {
        "success": True,
        "message": "Auth module is working!",
        "supabase_connected": SUPABASE_URL is not None
    }
