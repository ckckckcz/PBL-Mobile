"""
User management endpoints
"""

from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any
import logging
from ..models.schemas import UserResponse, ErrorResponse
from ..core.database import get_supabase

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["Users"])


@router.get("/users", response_model=UserResponse)
async def list_users():
    """
    Endpoint untuk mengambil daftar users dari Supabase

    Returns:
        UserResponse: Daftar users

    Raises:
        HTTPException: Jika terjadi error saat mengambil data
    """
    try:
        logger.info("[USERS] Fetching users from Supabase...")

        supabase = get_supabase()
        if not supabase:
            logger.error("[USERS] ✗ Supabase client not initialized")
            raise HTTPException(
                status_code=500,
                detail="Database connection not available"
            )

        response = supabase.table("users").select("*").execute()

        logger.info(f"[USERS] ✓ Successfully fetched {len(response.data)} users")

        return {
            "success": True,
            "data": response.data
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[USERS] ✗ Error fetching users: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching users: {str(e)}"
        )


@router.get("/users/{user_id}")
async def get_user(user_id: str):
    """
    Endpoint untuk mengambil detail user berdasarkan ID

    Args:
        user_id: ID user yang ingin diambil

    Returns:
        Dict: Detail user

    Raises:
        HTTPException: Jika user tidak ditemukan atau terjadi error
    """
    try:
        logger.info(f"[USERS] Fetching user with ID: {user_id}")

        supabase = get_supabase()
        if not supabase:
            logger.error("[USERS] ✗ Supabase client not initialized")
            raise HTTPException(
                status_code=500,
                detail="Database connection not available"
            )

        response = supabase.table("users").select("*").eq("id", user_id).execute()

        if not response.data or len(response.data) == 0:
            logger.warning(f"[USERS] User not found: {user_id}")
            raise HTTPException(
                status_code=404,
                detail=f"User with ID {user_id} not found"
            )

        logger.info(f"[USERS] ✓ Successfully fetched user: {user_id}")

        return {
            "success": True,
            "data": response.data[0]
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[USERS] ✗ Error fetching user: {e}")
        logger.exception(e)
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching user: {str(e)}"
        )
