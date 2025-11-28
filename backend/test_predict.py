"""
Test script untuk verifikasi prediction service dengan gambar asli
"""

import joblib
import numpy as np
from PIL import Image
from pathlib import Path
import sys

# Add app to path
sys.path.insert(0, str(Path(__file__).parent))

from app.services.image_service import ImagePreprocessor
from app.services.prediction_service import PredictionService

def test_prediction():
    print("=" * 80)
    print("TEST PREDICTION SERVICE")
    print("=" * 80)

    # Load model
    model_path = Path("model/model_v2.pkl")
    print(f"\n[1] Loading model from: {model_path}")
    print(f"    Model exists: {model_path.exists()}")

    model = joblib.load(model_path)
    print(f"    ✓ Model loaded")
    print(f"    Model keys: {list(model.keys())}")
    print(f"    Waste map: {model['waste_map']}")
    print(f"    Label encoder classes: {list(model['label_encoder'].classes_)}")

    # Initialize services
    print(f"\n[2] Initializing services...")
    image_preprocessor = ImagePreprocessor(target_size=(16, 16))
    prediction_service = PredictionService(model)
    print(f"    ✓ Services initialized")

    # Test with dummy image (create a grayscale gradient image)
    print(f"\n[3] Creating test image...")
    # Create 16x16 grayscale image with pattern
    img_array = np.random.randint(0, 255, (16, 16, 3), dtype=np.uint8)
    test_image = Image.fromarray(img_array)
    print(f"    ✓ Test image created: {test_image.size}, mode: {test_image.mode}")

    # Preprocess image
    print(f"\n[4] Preprocessing image...")
    features = image_preprocessor.preprocess(test_image)
    print(f"    ✓ Features extracted")
    print(f"    Feature shape: {features.shape}")
    print(f"    Feature range: [{features.min():.4f}, {features.max():.4f}]")
    print(f"    Sample features: {features[0][:5]}")

    # Predict
    print(f"\n[5] Running prediction...")
    result = prediction_service.predict(features)
    print(f"    ✓ Prediction complete")
    print(f"    Waste class: {result['waste_class']}")
    print(f"    Waste type: {result['waste_type']}")
    print(f"    Category: {result['category']}")
    print(f"    Confidence: {result['confidence']:.2f}%")

    # Format response
    print(f"\n[6] Formatting response...")
    response = prediction_service.format_response(result)
    print(f"    ✓ Response formatted")
    print(f"\n    Response structure:")
    print(f"    - success: {response['success']}")
    print(f"    - wasteType: {response['data']['wasteType']}")
    print(f"    - category: {response['data']['category']}")
    print(f"    - confidence: {response['data']['confidence']}%")
    print(f"    - tips count: {len(response['data']['tips'])}")
    print(f"    - description: {response['data']['description']}")

    print(f"\n    Probabilities per class:")
    for waste_name, prob_data in response['data']['modelInfo']['probabilitiesPerClass'].items():
        if isinstance(prob_data, dict):
            print(f"      {waste_name}: {prob_data['probability']:.2f}% -> {prob_data['category']}")
        else:
            print(f"      {waste_name}: {prob_data}")

    print("\n" + "=" * 80)
    print("TEST COMPLETED SUCCESSFULLY!")
    print("=" * 80)

if __name__ == "__main__":
    try:
        test_prediction()
    except Exception as e:
        print(f"\n[ERROR] Test failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
