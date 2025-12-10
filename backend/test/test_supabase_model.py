"""
Test script untuk memverifikasi loading model dari Supabase Storage
"""

import requests
import pickle
import sys
from pathlib import Path

# Configuration
MODEL_URL = "https://qmvxvnojbqkvdkewvdoi.supabase.co/storage/v1/object/public/Model/model_terbaru_v2.pkl"

def test_supabase_model_access():
    """Test akses ke model di Supabase Storage"""
    print("=" * 80)
    print("TEST SUPABASE MODEL ACCESS")
    print("=" * 80)

    print(f"\n[1] Testing URL accessibility...")
    print(f"    URL: {MODEL_URL}")

    try:
        # Test HEAD request untuk cek file exists
        print(f"\n[2] Checking if file exists (HEAD request)...")
        head_response = requests.head(MODEL_URL, timeout=10)
        print(f"    Status Code: {head_response.status_code}")
        print(f"    Content-Type: {head_response.headers.get('Content-Type', 'N/A')}")
        print(f"    Content-Length: {head_response.headers.get('Content-Length', 'N/A')} bytes")

        if head_response.status_code != 200:
            print(f"    ✗ FAILED: File not accessible (Status: {head_response.status_code})")
            return False

        print(f"    ✓ File is accessible!")

        # Download model
        print(f"\n[3] Downloading model...")
        response = requests.get(MODEL_URL, timeout=60)
        response.raise_for_status()

        file_size = len(response.content)
        file_size_mb = file_size / (1024 * 1024)
        print(f"    ✓ Model downloaded successfully!")
        print(f"    File size: {file_size:,} bytes ({file_size_mb:.2f} MB)")

        # Try to unpickle
        print(f"\n[4] Unpickling model...")
        model = pickle.loads(response.content)
        print(f"    ✓ Model unpickled successfully!")
        print(f"    Model type: {type(model)}")

        # Validate model structure
        print(f"\n[5] Validating model structure...")

        if not isinstance(model, dict):
            print(f"    ✗ FAILED: Model should be a dict, got {type(model)}")
            return False

        print(f"    Model is a dictionary ✓")
        print(f"    Keys: {list(model.keys())}")

        # Check required components
        required_keys = [
            'model',
            'scaler',
            'label_encoder',
            'waste_map'
        ]

        missing_keys = [key for key in required_keys if key not in model]

        if missing_keys:
            print(f"    ✗ FAILED: Missing required components: {missing_keys}")
            return False

        print(f"    ✓ All required components present!")

        # Validate specific components
        print(f"\n[6] Validating model components...")

        # XGBoost Model
        if hasattr(model['model'], 'predict'):
            print(f"    ✓ XGBoost model valid (type: {type(model['model']).__name__})")
        else:
            print(f"    ✗ XGBoost model invalid")
            return False

        # Scaler
        if hasattr(model['scaler'], 'transform'):
            scaler_type = type(model['scaler']).__name__
            print(f"    ✓ Scaler model valid (type: {scaler_type})")
        else:
            print(f"    ✗ Scaler model invalid")
            return False

        # Label Encoder
        if hasattr(model['label_encoder'], 'classes_'):
            classes = list(model['label_encoder'].classes_)
            print(f"    ✓ Label encoder valid ({len(classes)} classes)")
            print(f"    Classes: {classes}")
        else:
            print(f"    ✗ Label encoder invalid")
            return False

        # Waste Map
        if not isinstance(model['waste_map'], dict):
            print(f"    ✗ Waste map invalid")
            return False

        print(f"\n[7] Waste mapping:")
        for waste_class, category in model['waste_map'].items():
            print(f"    {waste_class:20s} -> {category}")

        # Threshold
        if 'threshold' in model:
            print(f"\n[8] Classification threshold: {model['threshold']}")

        print(f"\n" + "=" * 80)
        print("✓ ALL TESTS PASSED!")
        print("Model dari Supabase Storage siap digunakan!")
        print("=" * 80)

        return True

    except requests.exceptions.RequestException as e:
        print(f"\n    ✗ FAILED: Network error")
        print(f"    Error: {e}")
        return False

    except pickle.UnpicklingError as e:
        print(f"\n    ✗ FAILED: Unpickling error")
        print(f"    Error: {e}")
        print(f"    File mungkin corrupt atau bukan pickle file yang valid")
        return False

    except Exception as e:
        print(f"\n    ✗ FAILED: Unexpected error")
        print(f"    Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def compare_with_local():
    """Compare Supabase model with local model"""
    print("\n" + "=" * 80)
    print("COMPARING SUPABASE MODEL WITH LOCAL MODEL")
    print("=" * 80)

    local_path = Path("model/model_terbaru_v2.pkl")

    if not local_path.exists():
        print(f"\n⚠ Local model not found at: {local_path}")
        print(f"  Skipping comparison...")
        return

    try:
        print(f"\n[1] Loading local model...")
        import joblib
        local_model = joblib.load(local_path)
        print(f"    ✓ Local model loaded")

        print(f"\n[2] Downloading Supabase model...")
        response = requests.get(MODEL_URL, timeout=60)
        response.raise_for_status()
        supabase_model = pickle.loads(response.content)
        print(f"    ✓ Supabase model loaded")

        print(f"\n[3] Comparing models...")

        # Compare keys
        local_keys = set(local_model.keys()) if isinstance(local_model, dict) else set()
        supabase_keys = set(supabase_model.keys()) if isinstance(supabase_model, dict) else set()

        if local_keys == supabase_keys:
            print(f"    ✓ Both models have same keys: {list(local_keys)}")
        else:
            print(f"    ✗ Models have different keys!")
            print(f"    Local only: {local_keys - supabase_keys}")
            print(f"    Supabase only: {supabase_keys - local_keys}")
            return

        # Compare classes
        if isinstance(local_model, dict) and isinstance(supabase_model, dict):
            local_classes = list(local_model['label_encoder'].classes_)
            supabase_classes = list(supabase_model['label_encoder'].classes_)

            if local_classes == supabase_classes:
                print(f"    ✓ Both models have same classes ({len(local_classes)} classes)")
            else:
                print(f"    ✗ Models have different classes!")
                print(f"    Local: {local_classes}")
                print(f"    Supabase: {supabase_classes}")
                return

            # Compare threshold (if exists)
            local_threshold = local_model.get('threshold')
            supabase_threshold = supabase_model.get('threshold')

            if local_threshold == supabase_threshold:
                print(f"    ✓ Both models have same threshold: {local_threshold}")
            else:
                print(f"    ⚠ Models have different thresholds")
                print(f"    Local: {local_threshold}")
                print(f"    Supabase: {supabase_threshold}")

        print(f"\n✓ Models are compatible!")

    except Exception as e:
        print(f"\n✗ Comparison failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    print("\n" + "🚀" * 40)
    print("SUPABASE MODEL VERIFICATION TEST")
    print("🚀" * 40 + "\n")

    # Test Supabase access
    success = test_supabase_model_access()

    if not success:
        print("\n❌ FAILED: Model tidak bisa diload dari Supabase")
        print("\nTroubleshooting:")
        print("1. Cek apakah URL benar")
        print("2. Cek apakah file ada di Supabase Storage")
        print("3. Cek apakah bucket policy mengizinkan public read")
        print("4. Coba akses URL di browser")
        sys.exit(1)

    # Compare with local if exists
    compare_with_local()

    print("\n✅ SUCCESS: Model siap digunakan dari Supabase Storage!")
    print("\nAnda bisa deploy ke Vercel dengan percaya diri! 🎉")
    sys.exit(0)
