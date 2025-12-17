"""
Quick check script untuk verify server status dan auth endpoints.
Run this script untuk quick diagnosis.
"""

import requests
import json
from datetime import datetime

# GANTI URL INI SESUAI SERVER ANDA
BASE_URL = "https://ckckckcz-pilars-backend.hf.space"
# BASE_URL = "http://localhost:8000"  # Uncomment untuk local testing

def print_section(title):
    """Print section header"""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)

def check_url(url, method="GET", data=None):
    """Check a URL and return status"""
    try:
        if method == "GET":
            r = requests.get(url, timeout=5)
        else:
            r = requests.post(url, json=data, headers={"Content-Type": "application/json"}, timeout=5)

        return {
            "status": r.status_code,
            "success": r.status_code < 400,
            "response": r.text[:200]
        }
    except requests.exceptions.ConnectionError:
        return {"status": "CONNECTION_ERROR", "success": False, "response": "Cannot connect to server"}
    except requests.exceptions.Timeout:
        return {"status": "TIMEOUT", "success": False, "response": "Request timeout"}
    except Exception as e:
        return {"status": "ERROR", "success": False, "response": str(e)}

def main():
    print("\n" + "🔥" * 40)
    print("  PILAR SERVER QUICK CHECK")
    print("  " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("🔥" * 40)
    print(f"\nServer URL: {BASE_URL}\n")

    results = []

    # Test 1: Root endpoint
    print_section("1️⃣  Root Endpoint (Dashboard)")
    result = check_url(BASE_URL)
    print(f"   URL: {BASE_URL}")
    print(f"   Status: {result['status']}")
    print(f"   Result: {'✅ OK' if result['success'] else '❌ FAILED'}")
    results.append(("Root", result['success']))

    # Test 2: Health check
    print_section("2️⃣  Health Check")
    result = check_url(f"{BASE_URL}/health")
    print(f"   URL: {BASE_URL}/health")
    print(f"   Status: {result['status']}")
    print(f"   Result: {'✅ OK' if result['success'] else '❌ FAILED'}")
    if result['success']:
        try:
            data = json.loads(result['response'])
            print(f"   Response: {json.dumps(data, indent=2)}")
        except:
            pass
    results.append(("Health", result['success']))

    # Test 3: Auth test endpoint
    print_section("3️⃣  Auth Test Endpoint")
    result = check_url(f"{BASE_URL}/api/auth/test")
    print(f"   URL: {BASE_URL}/api/auth/test")
    print(f"   Status: {result['status']}")
    print(f"   Result: {'✅ OK' if result['success'] else '❌ FAILED'}")
    if result['success']:
        try:
            data = json.loads(result['response'])
            print(f"   Response: {json.dumps(data, indent=2)}")
        except:
            pass
    results.append(("Auth Test", result['success']))

    # Test 4: Login endpoint (dengan dummy data)
    print_section("4️⃣  Login Endpoint")
    result = check_url(
        f"{BASE_URL}/api/auth/login",
        method="POST",
        data={"email": "test@example.com", "password": "test123"}
    )
    print(f"   URL: {BASE_URL}/api/auth/login")
    print(f"   Method: POST")
    print(f"   Status: {result['status']}")
    # 401 or 400 is OK (means endpoint exists but credentials invalid)
    endpoint_exists = result['status'] in [401, 400, 200] or result['status'] == 422
    print(f"   Result: {'✅ Endpoint exists' if endpoint_exists else '❌ FAILED'}")
    if not result['success']:
        print(f"   Response: {result['response'][:100]}")
    results.append(("Login Endpoint", endpoint_exists))

    # Test 5: Database status
    print_section("5️⃣  Database Status")
    result = check_url(f"{BASE_URL}/api/dashboard/database-status")
    print(f"   URL: {BASE_URL}/api/dashboard/database-status")
    print(f"   Status: {result['status']}")
    print(f"   Result: {'✅ OK' if result['success'] else '❌ FAILED'}")
    if result['success']:
        try:
            data = json.loads(result['response'])
            print(f"   Connected: {data.get('connected', 'Unknown')}")
        except:
            pass
    results.append(("Database", result['success']))

    # Summary
    print_section("📊 SUMMARY")
    passed = sum(1 for _, success in results if success)
    total = len(results)

    for name, success in results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"   {name:20s} : {status}")

    print(f"\n   Total: {passed}/{total} tests passed")

    if passed == total:
        print("\n   🎉 All checks passed! Server is working correctly.")
    elif passed == 0:
        print("\n   ⚠️  Server not accessible! Please check:")
        print("      - Is server running?")
        print("      - Is URL correct?")
        print("      - Is firewall blocking?")
    else:
        print("\n   ⚠️  Some checks failed. Review the output above.")

    print("\n" + "=" * 80)

    # Flutter configuration check
    print_section("📱 FLUTTER CONFIGURATION")
    print("   Check your Flutter app's api_service.dart:")
    print(f"   static const String baseUrl = '{BASE_URL}';")
    print("   static const String loginEndpoint = '/api/auth/login';")
    print(f"\n   Full login URL should be:")
    print(f"   {BASE_URL}/api/auth/login")
    print("\n" + "=" * 80)

    # Next steps
    print_section("🔍 NEXT STEPS")
    if passed < total:
        print("   1. Check server logs for errors")
        print("   2. Verify .env file has correct SUPABASE credentials")
        print("   3. Ensure APP_MODE=production in .env")
        print("   4. Restart server: uvicorn app.main:app --host 0.0.0.0 --port 7860")
        print("   5. Check firewall/network settings")
    else:
        print("   1. Server is OK! Now test from Flutter app")
        print("   2. Make sure Flutter app uses correct baseUrl")
        print("   3. Check device/emulator network connection")
        print("   4. Try register a new user first")
        print("   5. Then try login with registered credentials")

    print("=" * 80 + "\n")

if __name__ == "__main__":
    main()
