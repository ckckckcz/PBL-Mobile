"""
Test script untuk complete authentication flow.
Test register → login → get user data.
"""

import requests
import json
import time
from datetime import datetime

# GANTI URL INI SESUAI SERVER ANDA
BASE_URL = "https://ckckckcz-pilars-backend.hf.space"
# BASE_URL = "http://localhost:8000"  # Uncomment untuk local testing

def print_header(title):
    """Print header with decorations"""
    print("\n" + "=" * 80)
    print(f"  🔥 {title}")
    print("=" * 80 + "\n")

def print_request(method, url, data=None):
    """Print request details"""
    print(f"📤 REQUEST:")
    print(f"   Method: {method}")
    print(f"   URL: {url}")
    if data:
        safe_data = data.copy()
        if 'password' in safe_data:
            safe_data['password'] = '***HIDDEN***'
        print(f"   Body: {json.dumps(safe_data, indent=6)}")

def print_response(status_code, response_text):
    """Print response details"""
    print(f"\n📥 RESPONSE:")
    print(f"   Status: {status_code}")

    try:
        data = json.loads(response_text)
        if 'token' in data:
            data['token'] = data['token'][:20] + '...' if len(data['token']) > 20 else data['token']
        print(f"   Body: {json.dumps(data, indent=6)}")
    except:
        print(f"   Body: {response_text[:200]}")

def test_register(email, password, full_name, phone=None):
    """Test user registration"""
    print_header("TEST 1: REGISTER NEW USER")

    url = f"{BASE_URL}/api/auth/register"
    data = {
        "email": email,
        "password": password,
        "full_name": full_name,
        "phone": phone
    }

    print_request("POST", url, data)

    try:
        response = requests.post(
            url,
            json=data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )

        print_response(response.status_code, response.text)

        if response.status_code == 200:
            print("\n✅ REGISTER SUCCESS!")
            result = response.json()
            return {
                "success": True,
                "token": result.get("token"),
                "user_id": result.get("data", {}).get("id")
            }
        else:
            print(f"\n⚠️  REGISTER FAILED with status {response.status_code}")
            return {"success": False}

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return {"success": False}

def test_login(email, password):
    """Test user login"""
    print_header("TEST 2: LOGIN USER")

    url = f"{BASE_URL}/api/auth/login"
    data = {
        "email": email,
        "password": password
    }

    print_request("POST", url, data)

    try:
        response = requests.post(
            url,
            json=data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )

        print_response(response.status_code, response.text)

        if response.status_code == 200:
            print("\n✅ LOGIN SUCCESS!")
            result = response.json()
            return {
                "success": True,
                "token": result.get("token"),
                "user_id": result.get("data", {}).get("id")
            }
        else:
            print(f"\n⚠️  LOGIN FAILED with status {response.status_code}")
            return {"success": False}

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return {"success": False}

def test_get_user(token):
    """Test get current user data"""
    print_header("TEST 3: GET USER DATA")

    url = f"{BASE_URL}/api/auth/me"

    print(f"📤 REQUEST:")
    print(f"   Method: GET")
    print(f"   URL: {url}")
    print(f"   Authorization: Bearer {token[:20]}...")

    try:
        response = requests.get(
            url,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            timeout=10
        )

        print_response(response.status_code, response.text)

        if response.status_code == 200:
            print("\n✅ GET USER DATA SUCCESS!")
            return {"success": True}
        else:
            print(f"\n⚠️  GET USER DATA FAILED with status {response.status_code}")
            return {"success": False}

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return {"success": False}

def test_logout(token):
    """Test logout"""
    print_header("TEST 4: LOGOUT")

    url = f"{BASE_URL}/api/auth/logout"

    print(f"📤 REQUEST:")
    print(f"   Method: POST")
    print(f"   URL: {url}")
    print(f"   Authorization: Bearer {token[:20]}...")

    try:
        response = requests.post(
            url,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            timeout=10
        )

        print_response(response.status_code, response.text)

        if response.status_code == 200:
            print("\n✅ LOGOUT SUCCESS!")
            return {"success": True}
        else:
            print(f"\n⚠️  LOGOUT FAILED with status {response.status_code}")
            return {"success": False}

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        return {"success": False}

def main():
    print("\n" + "🚀" * 40)
    print("  PILAR AUTH FLOW TEST")
    print("  " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("🚀" * 40)
    print(f"\nServer URL: {BASE_URL}\n")

    # Generate unique email using timestamp
    timestamp = int(time.time())
    test_email = f"testuser_{timestamp}@example.com"
    test_password = "testpass123"
    test_name = "Test User"
    test_phone = "081234567890"

    print(f"📝 Test Credentials:")
    print(f"   Email: {test_email}")
    print(f"   Password: {test_password}")
    print(f"   Name: {test_name}")
    print(f"   Phone: {test_phone}")

    results = []
    token = None

    # Test 1: Register
    register_result = test_register(test_email, test_password, test_name, test_phone)
    results.append(("Register", register_result["success"]))

    if register_result["success"]:
        token = register_result.get("token")

    time.sleep(1)

    # Test 2: Login
    login_result = test_login(test_email, test_password)
    results.append(("Login", login_result["success"]))

    if login_result["success"] and not token:
        token = login_result.get("token")

    time.sleep(1)

    # Test 3: Get user data
    if token:
        user_result = test_get_user(token)
        results.append(("Get User", user_result["success"]))
        time.sleep(1)
    else:
        print_header("TEST 3: GET USER DATA - SKIPPED (No token)")
        results.append(("Get User", False))

    # Test 4: Logout
    if token:
        logout_result = test_logout(token)
        results.append(("Logout", logout_result["success"]))
    else:
        print_header("TEST 4: LOGOUT - SKIPPED (No token)")
        results.append(("Logout", False))

    # Summary
    print_header("📊 TEST SUMMARY")

    passed = sum(1 for _, success in results if success)
    total = len(results)

    for name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"   {name:15s} : {status}")

    print(f"\n   Total: {passed}/{total} tests passed")
    print(f"   Success Rate: {(passed/total*100):.1f}%")

    if passed == total:
        print("\n   🎉 ALL TESTS PASSED!")
        print("   Your authentication system is working correctly.")
    elif passed == 0:
        print("\n   ❌ ALL TESTS FAILED!")
        print("   Please check:")
        print("      - Server is running")
        print("      - URL is correct")
        print("      - Database is connected")
        print("      - APP_MODE=production in .env")
    else:
        print("\n   ⚠️  SOME TESTS FAILED!")
        print("   Review the output above for details.")

    print("\n" + "=" * 80)

    # Troubleshooting tips
    print_header("🔧 TROUBLESHOOTING TIPS")

    if not results[0][1]:  # Register failed
        print("   ❌ Register Failed:")
        print("      - Check if email is already registered")
        print("      - Check Supabase connection")
        print("      - Check database table 'users' exists")
        print("      - Review server logs for errors")

    if not results[1][1]:  # Login failed
        print("   ❌ Login Failed:")
        print("      - Make sure user is registered first")
        print("      - Check password is correct")
        print("      - Check user is active in database")
        print("      - Review server logs for errors")

    if results[0][1] and results[1][1]:
        print("   ✅ Authentication is working!")
        print("      Now test from Flutter app:")
        print("      1. Update api_service.dart baseUrl if needed")
        print(f"         static const String baseUrl = '{BASE_URL}';")
        print("      2. Run Flutter app")
        print("      3. Try register or login")
        print("      4. Check logs in both Flutter and server")

    print("\n" + "=" * 80 + "\n")

if __name__ == "__main__":
    main()
