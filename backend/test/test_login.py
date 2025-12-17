#!/usr/bin/env python3
"""
Test script untuk testing API login backend
Jalankan: python test_login.py
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def test_health():
    """Test health check endpoint"""
    print_section("Testing Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_auth_test():
    """Test auth module"""
    print_section("Testing Auth Module")
    try:
        response = requests.get(f"{BASE_URL}/api/auth/test", timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_register(email="test@example.com", password="password123", full_name="Test User"):
    """Test register endpoint"""
    print_section(f"Testing Register - {email}")
    try:
        payload = {
            "email": email,
            "password": password,
            "full_name": full_name,
            "phone": "081234567890"
        }
        print(f"Payload: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            f"{BASE_URL}/api/auth/register",
            json=payload,
            timeout=5
        )
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200, response.json() if response.status_code == 200 else None
    except Exception as e:
        print(f"❌ Error: {e}")
        return False, None

def test_login(email="test@example.com", password="password123"):
    """Test login endpoint"""
    print_section(f"Testing Login - {email}")
    try:
        payload = {
            "email": email,
            "password": password
        }
        print(f"Payload: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
        f"{BASE_URL}/api/auth/login",
            json=payload,
            timeout=5
        )
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200, response.json() if response.status_code == 200 else None
    except Exception as e:
        print(f"❌ Error: {e}")
        return False, None

def test_get_me(token):
    """Test get current user endpoint"""
    print_section("Testing Get Current User (/me)")
    try:
        headers = {
            "Authorization": f"Bearer {token}"
        }
        print(f"Token: {token[:50]}...")
        
        response = requests.get(
            f"{BASE_URL}/api/auth/me",
            headers=headers,
            timeout=5
        )
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_invalid_login():
    """Test login dengan password yang salah"""
    print_section("Testing Invalid Login")
    try:
        payload = {
            "email": "test@example.com",
            "password": "wrongpassword"
        }
        print(f"Payload: {json.dumps(payload, indent=2)}")
        
        response = requests.post(
            f"{BASE_URL}/api/auth/login",
            json=payload,
            timeout=5
        )
        print(f"\nStatus Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        print(f"✓ Correctly returned error (should be 401): {response.status_code == 401}")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    print("🔐 API Login Testing Suite")
    print(f"Base URL: {BASE_URL}")
    
    # Test 1: Health Check
    health_ok = test_health()
    if not health_ok:
        print("\n❌ Backend tidak berjalan! Jalankan: python run.py")
        return
    
    # Test 2: Auth Module
    auth_ok = test_auth_test()
    if not auth_ok:
        print("\n❌ Auth module tidak berfungsi!")
        return
    
    # Test 3: Register
    register_ok, register_data = test_register()
    if not register_ok:
        print("\n⚠️  Register gagal (mungkin email sudah terdaftar)")
    else:
        print("\n✓ Register berhasil!")
    
    # Test 4: Login
    login_ok, login_data = test_login()
    if login_ok:
        print("\n✓ Login berhasil!")
        token = login_data.get('token')
        if token:
            # Test 5: Get Me
            me_ok = test_get_me(token)
            if me_ok:
                print("\n✓ Get current user berhasil!")
            else:
                print("\n❌ Get current user gagal!")
    else:
        print("\n❌ Login gagal!")
    
    # Test 6: Invalid Login
    test_invalid_login()
    
    # Summary
    print_section("Test Summary")
    print(f"✓ Health Check: {'PASS' if health_ok else 'FAIL'}")
    print(f"✓ Auth Module: {'PASS' if auth_ok else 'FAIL'}")
    print(f"✓ Register: {'PASS' if register_ok else 'FAIL (expected jika email sudah terdaftar)'}")
    print(f"✓ Login: {'PASS' if login_ok else 'FAIL'}")

if __name__ == "__main__":
    main()
