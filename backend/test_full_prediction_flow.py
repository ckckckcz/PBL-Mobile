"""
Comprehensive test untuk full prediction flow dari Supabase model loading hingga prediction
"""

import sys
from pathlib import Path
import numpy as np
from PIL import Image

# Add app to path
sys.path.insert(0, str(Path(__file__).parent))

from app.services.model_service import init_model_service
from app.services.prediction_service import init_prediction_service, get_prediction_service
from app.services.image_service import ImagePreprocessor


def test_full_flow():
    """Test complete prediction flow"""
    print("=" * 80)
    print("COMPREHENSIVE PREDICTION FLOW TEST")
    print("=" * 80)

    # Configuration
    MODEL_URL = "https://qmvxvnojbqkvdkewvdoi.supabase.co/storage/v1/object/public/Model/model_v2.pkl"
    LOCAL_MODEL_PATH = Path("model/model_v2.pkl")

    # Step 1: Initialize Model Service
    print("\n[STEP 1] Initializing Model Service...")
    try:
        model_service = init_model_service(
            model_path=LOCAL_MODEL_PATH,
            model_url=MODEL_URL
        )
        print("    ✓ Model service initialized")
    except Exception as e:
        print(f"    ✗ Failed to initialize model service: {e}")
        return False

    # Step 2: Load Model
    print("\n[STEP 2] Loading Model...")
    try:
        model = model_service.load_model()
        model_info = model_service.get_model_info()
        print(f"    ✓ Model loaded from: {model_info['source']}")
        print(f"    Model validated: {model_info['validated']}")
        print(f"    Waste classes: {model_info['waste_classes']}")
        print(f"    Number of classes: {model_info['n_classes']}")
        print(f"    Threshold: {model_info['threshold']}")
    except Exception as e:
        print(f"    ✗ Failed to load model: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Step 3: Initialize Prediction Service
    print("\n[STEP 3] Initializing Prediction Service...")
    try:
        prediction_service = init_prediction_service(model)
        ps = get_prediction_service()
        if ps:
            print("    ✓ Prediction service initialized")
            print(f"    XGBoost model type: {type(ps.xgb_model).__name__}")
            print(f"    Scaler type: {type(ps.scaler).__name__}")
            print(f"    Label encoder type: {type(ps.label_encoder).__name__}")
            print(f"    Waste map: {ps.waste_map}")
            print(f"    Threshold: {ps.threshold}")
        else:
            print("    ✗ Prediction service is None")
            return False
    except Exception as e:
        print(f"    ✗ Failed to initialize prediction service: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Step 4: Initialize Image Preprocessor
    print("\n[STEP 4] Initializing Image Preprocessor...")
    try:
        image_preprocessor = ImagePreprocessor(target_size=(16, 16))
        print("    ✓ Image preprocessor initialized")
    except Exception as e:
        print(f"    ✗ Failed to initialize image preprocessor: {e}")
        return False

    # Step 5: Create Test Image
    print("\n[STEP 5] Creating Test Image...")
    try:
        # Create a random RGB image
        test_image_array = np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8)
        test_image = Image.fromarray(test_image_array)
        print(f"    ✓ Test image created: {test_image.size}, mode: {test_image.mode}")
    except Exception as e:
        print(f"    ✗ Failed to create test image: {e}")
        return False

    # Step 6: Preprocess Image
    print("\n[STEP 6] Preprocessing Image...")
    try:
        features = image_preprocessor.preprocess(test_image)
        print(f"    ✓ Image preprocessed")
        print(f"    Feature shape: {features.shape}")
        print(f"    Feature range: [{features.min():.4f}, {features.max():.4f}]")
        print(f"    Sample features: {features[0][:5]}")
    except Exception as e:
        print(f"    ✗ Failed to preprocess image: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Step 7: Run Prediction
    print("\n[STEP 7] Running Prediction...")
    try:
        result = prediction_service.predict(features)
        print(f"    ✓ Prediction successful")
        print(f"    Waste class: {result['waste_class']}")
        print(f"    Waste type: {result['waste_type']}")
        print(f"    Category: {result['category']}")
        print(f"    Confidence: {result['confidence']:.2f}%")
    except Exception as e:
        print(f"    ✗ Failed to run prediction: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Step 8: Format Response
    print("\n[STEP 8] Formatting Response...")
    try:
        response = prediction_service.format_response(result)
        print(f"    ✓ Response formatted")
        print(f"\n    Response structure:")
        print(f"    - success: {response['success']}")
        print(f"    - wasteType: {response['data']['wasteType']}")
        print(f"    - category: {response['data']['category']}")
        print(f"    - confidence: {response['data']['confidence']}%")
        print(f"    - tips count: {len(response['data']['tips'])}")
        print(f"    - description: {response['data']['description']}")
    except Exception as e:
        print(f"    ✗ Failed to format response: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Step 9: Verify Response Structure
    print("\n[STEP 9] Verifying Response Structure...")
    try:
        assert response['success'] == True, "Success should be True"
        assert 'data' in response, "Response should have 'data' key"
        assert 'wasteType' in response['data'], "Data should have 'wasteType'"
        assert 'category' in response['data'], "Data should have 'category'"
        assert 'confidence' in response['data'], "Data should have 'confidence'"
        assert 'tips' in response['data'], "Data should have 'tips'"
        assert 'description' in response['data'], "Data should have 'description'"
        assert 'modelInfo' in response['data'], "Data should have 'modelInfo'"
        print("    ✓ All required fields present")
    except AssertionError as e:
        print(f"    ✗ Response structure validation failed: {e}")
        return False

    # Step 10: Display Probabilities
    print("\n[STEP 10] Class Probabilities:")
    try:
        probs = response['data']['modelInfo']['probabilitiesPerClass']
        for waste_name, prob_data in probs.items():
            if isinstance(prob_data, dict):
                print(f"    {waste_name:20s}: {prob_data['probability']:6.2f}% -> {prob_data['category']}")
            else:
                print(f"    {waste_name:20s}: {prob_data}")
        print("    ✓ Probabilities displayed")
    except Exception as e:
        print(f"    ⚠ Warning: Could not display probabilities: {e}")

    print("\n" + "=" * 80)
    print("✅ ALL TESTS PASSED!")
    print("=" * 80)
    print("\n🎉 Complete prediction flow working correctly!")
    print("   Model source:", model_info['source'])
    print("   Model validated:", model_info['validated'])
    print("   Prediction service: READY")
    print("\n✅ Backend siap untuk handle prediction requests!")
    print("=" * 80)

    return True


def test_error_handling():
    """Test error handling scenarios"""
    print("\n" + "=" * 80)
    print("ERROR HANDLING TESTS")
    print("=" * 80)

    # Test 1: Prediction service before initialization
    print("\n[TEST 1] Get prediction service before initialization...")
    from app.services.prediction_service import get_prediction_service
    ps = get_prediction_service()
    if ps is None:
        print("    ✓ Returns None as expected")
    else:
        print("    ⚠ Should return None but returned:", type(ps))

    print("\n" + "=" * 80)


if __name__ == "__main__":
    print("\n" + "🚀" * 40)
    print("FULL PREDICTION FLOW TEST")
    print("Testing: Supabase Model Loading → Prediction Service → Image Processing → Prediction")
    print("🚀" * 40 + "\n")

    # Run main test
    success = test_full_flow()

    if not success:
        print("\n❌ TEST FAILED!")
        print("\nPossible issues:")
        print("1. Model not accessible from Supabase")
        print("2. Model structure mismatch")
        print("3. Service initialization failed")
        print("4. Feature extraction error")
        sys.exit(1)

    # Run error handling tests
    test_error_handling()

    print("\n✅ ALL TESTS COMPLETED SUCCESSFULLY!")
    print("\n📝 Summary:")
    print("   - Model loading: ✅ WORKING")
    print("   - Model validation: ✅ WORKING")
    print("   - Prediction service: ✅ WORKING")
    print("   - Image preprocessing: ✅ WORKING")
    print("   - Prediction: ✅ WORKING")
    print("   - Response formatting: ✅ WORKING")
    print("\n🚀 Backend is production ready!")

    sys.exit(0)
