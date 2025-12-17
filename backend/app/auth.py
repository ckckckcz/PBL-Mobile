from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr, Field
from supabase import create_client
from .core.config import SUPABASE_URL, SUPABASE_KEY
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

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    new_password: str = Field(..., min_length=6)

class ChangePasswordRequest(BaseModel):
    current_password: str = Field(..., min_length=6)
    new_password: str = Field(..., min_length=6)

class LoginResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None
    token: Optional[str] = None

class StandardResponse(BaseModel):
    success: bool
    message: str

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
    logger.info("=" * 80)
    logger.info("[LOGIN] ⚡ LOGIN REQUEST RECEIVED!")
    logger.info(f"[LOGIN] Email: {request.email}")
    logger.info(f"[LOGIN] Timestamp: {datetime.utcnow().isoformat()}")
    logger.info("=" * 80)

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
            "id": str(user['id']),  # Convert to string for Flutter compatibility
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
    Register endpoint untuk membuat user baru

    - **email**: Email yang valid dan belum terdaftar
    - **password**: Password minimal 6 karakter
    - **full_name**: Nama lengkap user
    - **phone**: Nomor telepon (opsional)

    Returns:
    - User data dan JWT token jika berhasil
    """
    logger.info("=" * 80)
    logger.info("[REGISTER] ⚡ REGISTER REQUEST RECEIVED!")
    logger.info(f"[REGISTER] Email: {request.email}")
    logger.info(f"[REGISTER] Full Name: {request.full_name}")
    logger.info(f"[REGISTER] Timestamp: {datetime.utcnow().isoformat()}")
    logger.info("=" * 80)

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
            "id": str(user['id']),  # Convert to string for Flutter compatibility
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
            "id": str(user['id']),  # Convert to string for Flutter compatibility
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

@router.post("/forgot-password", response_model=StandardResponse)
async def forgot_password(request: ForgotPasswordRequest):
    """
    Forgot password endpoint - Verify email exists

    - **email**: Email user yang terdaftar

    Returns:
    - Success message jika email ditemukan
    - Error jika email tidak terdaftar

    Note: Endpoint ini hanya verify email.
    Untuk reset password, gunakan /reset-password
    """
    logger.info(f"[FORGOT_PASSWORD] Request for email: {request.email}")

    try:
        # Check if email exists
        response = supabase.table('users').select('id, email, full_name').eq('email', request.email).execute()

        if response.data and len(response.data) > 0:
            logger.info(f"[FORGOT_PASSWORD] ✓ Email found: {request.email}")
            return StandardResponse(
                success=True,
                message="Email ditemukan. Silakan masukkan kata sandi baru Anda."
            )
        else:
            logger.warning(f"[FORGOT_PASSWORD] Email not found: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Email tidak terdaftar dalam sistem kami."
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[FORGOT_PASSWORD] Error: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan pada server. Silakan coba lagi."
        )


@router.post("/reset-password", response_model=StandardResponse)
async def reset_password(request: ResetPasswordRequest):
    """
    Reset password endpoint (tanpa email verification)

    - **email**: Email user yang terdaftar
    - **new_password**: Password baru (minimal 6 karakter)

    Returns:
    - Success message jika password berhasil direset

    Note: Untuk development tanpa email verification.
    Di production, tambahkan token/OTP verification.
    """
    logger.info(f"[RESET_PASSWORD] Request for email: {request.email}")

    try:
        # Check if email exists
        response = supabase.table('users').select('*').eq('email', request.email).execute()

        if not response.data or len(response.data) == 0:
            logger.warning(f"[RESET_PASSWORD] Email not found: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Email tidak terdaftar dalam sistem kami."
            )

        user = response.data[0]

        # Check if new password is same as current (optional security)
        if verify_password(request.new_password, user['password_hash']):
            logger.warning(f"[RESET_PASSWORD] New password same as current for: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Kata sandi baru tidak boleh sama dengan kata sandi lama."
            )

        # Hash new password
        new_password_hash = hash_password(request.new_password)

        # Update password
        update_response = supabase.table('users').update({
            'password_hash': new_password_hash,
            'updated_at': datetime.utcnow().isoformat()
        }).eq('id', user['id']).execute()

        if not update_response.data or len(update_response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Gagal mengubah kata sandi. Silakan coba lagi."
            )

        logger.info(f"[RESET_PASSWORD] ✓ Password reset successfully for: {request.email}")

        return StandardResponse(
            success=True,
            message="Kata sandi berhasil diubah. Silakan login dengan kata sandi baru Anda."
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[RESET_PASSWORD] Error: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan pada server. Silakan coba lagi."
        )


@router.post("/change-password", response_model=StandardResponse)
async def change_password(
    request: ChangePasswordRequest,
    user_id: str = Depends(get_current_user)
):
    """
    Change password endpoint (requires authentication)

    Headers:
    - **Authorization**: Bearer {token}

    Request Body:
    - **current_password**: Password saat ini
    - **new_password**: Password baru (minimal 6 karakter)

    Returns:
    - Success message jika password berhasil diubah
    """
    logger.info(f"[CHANGE_PASSWORD] Request from user: {user_id}")

    try:
        # Get user data
        response = supabase.table('users').select('*').eq('id', user_id).execute()

        if not response.data or len(response.data) == 0:
            logger.warning(f"[CHANGE_PASSWORD] User not found: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User tidak ditemukan"
            )

        user = response.data[0]

        # Verify current password
        if not verify_password(request.current_password, user['password_hash']):
            logger.warning(f"[CHANGE_PASSWORD] Invalid current password for user: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Kata sandi saat ini salah"
            )

        # Check if new password is same as current
        if verify_password(request.new_password, user['password_hash']):
            logger.warning(f"[CHANGE_PASSWORD] New password same as current for user: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Kata sandi baru tidak boleh sama dengan kata sandi saat ini"
            )

        # Hash new password
        new_password_hash = hash_password(request.new_password)

        # Update password
        update_response = supabase.table('users').update({
            'password_hash': new_password_hash,
            'updated_at': datetime.utcnow().isoformat()
        }).eq('id', user_id).execute()

        if not update_response.data or len(update_response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Gagal mengubah kata sandi. Silakan coba lagi."
            )

        logger.info(f"[CHANGE_PASSWORD] ✓ Password changed successfully for user: {user_id}")

        return StandardResponse(
            success=True,
            message="Kata sandi berhasil diubah"
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[CHANGE_PASSWORD] Error: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan pada server. Silakan coba lagi."
        )


@router.get("/test")
async def test_auth():
    """Test endpoint untuk memastikan auth module berfungsi"""
    return {
        "success": True,
        "message": "Auth module is working!",
        "supabase_connected": SUPABASE_URL is not None
    }
