#!/usr/bin/env python3
"""
Script untuk test koneksi Supabase dan verify password hash
Jalankan: python test_supabase.py
"""

import bcrypt
import os
from dotenv import load_dotenv
from supabase import create_client

# Load environment variables
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

def print_section(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")

def test_supabase_connection():
    """Test koneksi ke Supabase"""
    print_section("Testing Supabase Connection")
    
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("❌ SUPABASE_URL atau SUPABASE_KEY tidak ada di .env file!")
        print(f"   SUPABASE_URL: {SUPABASE_URL}")
        print(f"   SUPABASE_KEY: {'SET' if SUPABASE_KEY else 'NOT SET'}")
        return False
    
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✓ Supabase client initialized")
        print(f"  URL: {SUPABASE_URL}")
        print(f"  Key: {SUPABASE_KEY[:20]}...")
        return True, supabase
    except Exception as e:
        print(f"❌ Error connecting to Supabase: {e}")
        return False, None

def test_get_users(supabase):
    """Get semua users dari Supabase"""
    print_section("Fetching Users from Supabase")
    
    try:
        response = supabase.table('users').select('id, email, full_name, password_hash').execute()
        
        if not response.data:
            print("❌ Tidak ada users di database!")
            return []
        
        print(f"✓ Found {len(response.data)} users:\n")
        
        for i, user in enumerate(response.data, 1):
            email = user.get('email', 'N/A')
            full_name = user.get('full_name', 'N/A')
            password_hash = user.get('password_hash', 'N/A')
            
            # Check if password is valid bcrypt hash
            is_valid_hash = password_hash.startswith('$2')
            hash_status = "✓ Valid bcrypt hash" if is_valid_hash else "❌ INVALID (plaintext or wrong format)"
            
            print(f"  [{i}] {email}")
            print(f"      Name: {full_name}")
            print(f"      Hash: {password_hash[:30]}...")
            print(f"      Status: {hash_status}")
            print()
        
        return response.data
    except Exception as e:
        print(f"❌ Error fetching users: {e}")
        return []

def verify_password_with_hash(plain_password: str, hashed_password: str):
    """Verify plaintext password dengan hash"""
    try:
        return bcrypt.checkpw(
            plain_password.encode('utf-8'),
            hashed_password.encode('utf-8')
        )
    except Exception as e:
        print(f"     Error verifying: {e}")
        return False

def test_password_verification(users):
    """Test password verification untuk setiap user"""
    print_section("Testing Password Verification")
    
    test_password = "password123"
    print(f"Testing password: {test_password}\n")
    
    for user in users:
        email = user.get('email', 'N/A')
        password_hash = user.get('password_hash', '')
        
        print(f"User: {email}")
        
        # Check if it's a valid bcrypt hash
        if not password_hash.startswith('$2'):
            print(f"  ❌ Invalid hash format (not bcrypt): {password_hash[:30]}...")
            print()
            continue
        
        # Try to verify password
        is_correct = verify_password_with_hash(test_password, password_hash)
        
        if is_correct:
            print(f"  ✓ Password verification SUCCESS")
            print(f"    Hash: {password_hash[:40]}...")
        else:
            print(f"  ❌ Password verification FAILED")
            print(f"    Hash: {password_hash[:40]}...")
        print()

def generate_correct_hash(password: str = "password123"):
    """Generate correct bcrypt hash"""
    print_section("Generating Correct Password Hash")
    
    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    password_hash = hashed.decode('utf-8')
    
    print(f"Password: {password}")
    print(f"Hash:     {password_hash}")
    print()
    print("Use this hash to update passwords in Supabase:")
    print()
    print("UPDATE public.users")
    print(f"SET password_hash = '{password_hash}'")
    print("WHERE email = 'admin@pilar.com';")
    print()

def main():
    print("="*70)
    print("  SUPABASE CONNECTION & PASSWORD VERIFICATION TEST")
    print("="*70)
    
    # Test 1: Supabase Connection
    result = test_supabase_connection()
    if not result or not result[0]:
        print("\n❌ Cannot connect to Supabase. Check your .env file!")
        return
    
    supabase = result[1]
    
    # Test 2: Fetch Users
    users = test_get_users(supabase)
    if not users:
        print("\n❌ No users found in database!")
        return
    
    # Test 3: Verify Passwords
    test_password_verification(users)
    
    # Test 4: Generate Hash
    generate_correct_hash()
    
    print("="*70)
    print("  SUMMARY")
    print("="*70)
    print()
    print("If password verification FAILED:")
    print("1. Copy the hash from 'Generating Correct Password Hash'")
    print("2. Update passwords in Supabase using SQL")
    print("3. Run this test again to verify")
    print()

if __name__ == "__main__":
    main()
