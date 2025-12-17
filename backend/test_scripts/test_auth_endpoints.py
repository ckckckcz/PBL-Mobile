"""
Test script untuk mengecek apakah auth endpoints bisa diakses.
Run this script ketika server sudah berjalan.
"""

import requests
import json

# URL server - ganti sesuai dengan URL server Anda
BASE_URL = "https://ckckckcz-pilars-backend.hf.space"
# BASE_URL = "http://localhost:8000"  # Uncomment untuk local testing

def test_endpoint(method, endpoint, data=None, headers=None):
    """Test sebuah endpoint dan print hasilnya"""
    url = f"{BASE_URL}{endpoint}"
    print("\n" + "=" * 80)
    print(f"Testing: {method} {url}")
    print("=" * 80)

    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=10)
        else:
            print(f"❌ Method {method} not supported")
            return False

        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")

        try:
            response_data = response.json()
            print(f"Response Body: {json.dumps(response_data, indent=2)}")
        except:
            print(f"Response Body (raw): {response.text[:500]}")

        if response.status_code < 400:
            print("✅ SUCCESS")
            return True
        else:
            print(f"⚠️  Failed with status {response.status_code}")
            return False

    except requests.exceptions.ConnectionError as e:
        print(f"❌ CONNECTION ERROR: {e}")
        print("Server mungkin tidak running atau URL salah!")
        return False
    except requests.exceptions.Timeout:
        print("❌ TIMEOUT: Request took too long")
        return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def main():
    print("\n" + "🔥" * 40)
    print("AUTH ENDPOINTS TEST SCRIPT")
    print("🔥" * 40)
    print(f"\nBase URL: {BASE_URL}")
    print("\n")

    # Test 1: Health check
    print("\n📌 Test 1: Health Check")
    test_endpoint("GET", "/health")

    # Test 2: Auth test endpoint
    print("\n📌 Test 2: Auth Test Endpoint")
    test_endpoint("GET", "/api/auth/test")

    # Test 3: Login endpoint dengan invalid credentials (untuk test apakah endpoint exists)
    print("\n📌 Test 3: Login Endpoint (invalid credentials - just testing if endpoint exists)")
    login_data = {
        "email": "test@example.com",
        "password": "testpass123"
    }
    test_endpoint("POST", "/api/auth/login", data=login_data)

    # Test 4: Register endpoint dengan data test
    print("\n📌 Test 4: Register Endpoint (test data)")
    register_data = {
        "email": f"testuser_{int(time.time())}@example.com",
        "password": "testpass123",
        "full_name": "Test User",
        "phone": "081234567890"
    }
    test_endpoint("POST", "/api/auth/register", data=register_data)

    print("\n" + "=" * 80)
    print("✅ Testing selesai!")
    print("=" * 80)
    print("\nCatatan:")
    print("- Jika semua test CONNECTION ERROR, pastikan server sudah running")
    print("- Jika dapat response 404, berarti router tidak termount dengan benar")
    print("- Jika dapat response 401/400, berarti endpoint ada tapi credentials salah (ini normal)")
    print("=" * 80)

if __name__ == "__main__":
    import time
    main()
