"""
Test script untuk memastikan API siap deploy ke Hugging Face
Run this before deployment: python test_local.py
"""

import sys
from pathlib import Path
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

def test_model_exists():
    """Test 1: Verify model file exists"""
    logger.info("=" * 60)
    logger.info("TEST 1: Checking model file existence")
    logger.info("=" * 60)

    model_path = Path(__file__).parent / "model" / "model_terbaru_v2.pkl"

    if model_path.exists():
        size_mb = model_path.stat().st_size / (1024 * 1024)
        logger.info(f"✅ Model file found: {model_path}")
        logger.info(f"✅ Model size: {size_mb:.2f} MB")
        return True
    else:
        logger.error(f"❌ Model file NOT found at: {model_path}")
        logger.error("❌ Please ensure model_terbaru_v2.pkl exists in backend/model/")
        return False


def test_model_loading():
    """Test 2: Try loading model"""
    logger.info("\n" + "=" * 60)
    logger.info("TEST 2: Testing model loading")
    logger.info("=" * 60)

    try:
        import joblib
        model_path = Path(__file__).parent / "model" / "model_terbaru_v2.pkl"

        logger.info("Loading model...")
        model = joblib.load(model_path)

        if isinstance(model, dict):
            logger.info(f"✅ Model loaded successfully")
            logger.info(f"✅ Model type: {type(model)}")
            logger.info(f"✅ Model components: {list(model.keys())}")

            # Check required components
            required = ['model', 'scaler', 'label_encoder', 'waste_map']
            missing = [k for k in required if k not in model]

            if missing:
                logger.error(f"❌ Missing components: {missing}")
                return False

            logger.info(f"✅ All required components present")
            logger.info(f"✅ Number of classes: {len(model['label_encoder'].classes_)}")
            logger.info(f"✅ Waste classes: {list(model['label_encoder'].classes_)}")
            return True
        else:
            logger.error(f"❌ Model is not a dictionary: {type(model)}")
            return False

    except Exception as e:
        logger.error(f"❌ Error loading model: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


def test_dependencies():
    """Test 3: Check all required dependencies"""
    logger.info("\n" + "=" * 60)
    logger.info("TEST 3: Checking dependencies")
    logger.info("=" * 60)

    required_packages = {
        'fastapi': 'FastAPI',
        'uvicorn': 'Uvicorn',
        'PIL': 'Pillow',
        'numpy': 'NumPy',
        'sklearn': 'scikit-learn',
        'xgboost': 'XGBoost',
        'joblib': 'joblib',
        'cv2': 'opencv-python'
    }

    all_ok = True
    for package, name in required_packages.items():
        try:
            __import__(package)
            logger.info(f"✅ {name} installed")
        except ImportError:
            logger.error(f"❌ {name} NOT installed")
            all_ok = False

    return all_ok


def test_app_structure():
    """Test 4: Verify app structure"""
    logger.info("\n" + "=" * 60)
    logger.info("TEST 4: Checking app structure")
    logger.info("=" * 60)

    base_dir = Path(__file__).parent

    required_files = [
        "app/main.py",
        "app/api/predict.py",
        "app/api/health.py",
        "app/services/model_service.py",
        "app/services/prediction_service.py",
        "app/services/image_service.py",
        "model/model_terbaru_v2.pkl"
    ]

    all_ok = True
    for file_path in required_files:
        full_path = base_dir / file_path
        if full_path.exists():
            logger.info(f"✅ {file_path}")
        else:
            logger.error(f"❌ {file_path} NOT found")
            all_ok = False

    return all_ok


def test_imports():
    """Test 5: Test importing main app"""
    logger.info("\n" + "=" * 60)
    logger.info("TEST 5: Testing app imports")
    logger.info("=" * 60)

    try:
        sys.path.insert(0, str(Path(__file__).parent))

        logger.info("Importing FastAPI app...")
        from app.main import app
        logger.info(f"✅ App imported successfully")
        logger.info(f"✅ App title: {app.title}")
        logger.info(f"✅ App version: {app.version}")

        # Check routes
        routes = [route.path for route in app.routes]
        logger.info(f"✅ Available routes: {routes}")

        expected_routes = ["/", "/health", "/api/predict"]
        for route in expected_routes:
            if any(route in r for r in routes):
                logger.info(f"✅ Route {route} registered")
            else:
                logger.error(f"❌ Route {route} NOT found")
                return False

        return True

    except Exception as e:
        logger.error(f"❌ Error importing app: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


def test_model_service():
    """Test 6: Test model service initialization"""
    logger.info("\n" + "=" * 60)
    logger.info("TEST 6: Testing model service")
    logger.info("=" * 60)

    try:
        sys.path.insert(0, str(Path(__file__).parent))

        from app.services.model_service import init_model_service

        model_path = Path(__file__).parent / "model" / "model_terbaru_v2.pkl"

        logger.info("Initializing model service...")
        model_service = init_model_service(model_path=model_path)

        logger.info("Loading model...")
        model = model_service.load_model()

        if model_service.is_loaded():
            logger.info("✅ Model service initialized successfully")
            logger.info("✅ Model loaded and validated")

            info = model_service.get_model_info()
            logger.info(f"✅ Source: {info['source']}")
            logger.info(f"✅ Classes: {info['n_classes']}")
            logger.info(f"✅ Validated: {info['validated']}")
            return True
        else:
            logger.error("❌ Model service failed to initialize")
            return False

    except Exception as e:
        logger.error(f"❌ Error testing model service: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


def test_prediction_service():
    """Test 7: Test prediction service"""
    logger.info("\n" + "=" * 60)
    logger.info("TEST 7: Testing prediction service")
    logger.info("=" * 60)

    try:
        sys.path.insert(0, str(Path(__file__).parent))

        from app.services.model_service import get_model_service, init_model_service
        from app.services.prediction_service import init_prediction_service
        import numpy as np

        # Ensure model service is initialized
        model_service = get_model_service()
        if not model_service:
            logger.info("Model service not initialized, initializing now...")
            model_path = Path(__file__).parent / "model" / "model_terbaru_v2.pkl"
            model_service = init_model_service(model_path=model_path)
            model_service.load_model()

        model = model_service.get_model()
        if not model:
            logger.error("❌ Model not loaded")
            return False

        logger.info("Initializing prediction service...")
        pred_service = init_prediction_service(model)

        # Test with dummy features (38 features as expected by model)
        logger.info("Testing prediction with dummy data...")
        dummy_features = np.random.rand(1, 38).astype(np.float32)

        result = pred_service.predict(dummy_features)

        logger.info("✅ Prediction service working")
        logger.info(f"✅ Predicted: {result['waste_type']}")
        logger.info(f"✅ Category: {result['category']}")
        logger.info(f"✅ Confidence: {result['confidence']:.2f}%")

        return True

    except Exception as e:
        logger.error(f"❌ Error testing prediction service: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


def run_all_tests():
    """Run all tests and report results"""
    logger.info("\n" + "🚀" * 30)
    logger.info("PILAR API - PRE-DEPLOYMENT TESTS")
    logger.info("🚀" * 30 + "\n")

    tests = [
        ("Model File Exists", test_model_exists),
        ("Model Loading", test_model_loading),
        ("Dependencies", test_dependencies),
        ("App Structure", test_app_structure),
        ("App Imports", test_imports),
        ("Model Service", test_model_service),
        ("Prediction Service", test_prediction_service),
    ]

    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            logger.error(f"❌ Test '{name}' crashed: {e}")
            results.append((name, False))

    # Summary
    logger.info("\n" + "=" * 60)
    logger.info("TEST SUMMARY")
    logger.info("=" * 60)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        logger.info(f"{status} - {name}")

    logger.info("=" * 60)
    logger.info(f"Total: {passed}/{total} tests passed")
    logger.info("=" * 60)

    if passed == total:
        logger.info("\n🎉 ALL TESTS PASSED! Ready for Hugging Face deployment!")
        logger.info("\nNext steps:")
        logger.info("1. Create Dockerfile")
        logger.info("2. Push to Hugging Face Space")
        logger.info("3. Wait for build to complete")
        logger.info("4. Test deployed API")
        return True
    else:
        logger.error(f"\n⚠️  {total - passed} test(s) failed. Please fix before deployment.")
        return False


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
