"""
Test script untuk verifikasi prediction service dengan gambar asli
Model V2 compatible test
"""

import joblib
import numpy as np
from PIL import Image
from pathlib import Path
import sys
import cv2

# Add backend directory to path (parent of parent)
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.services.v2.image_preprocessor import ImagePreprocessorV2
from app.services.prediction_service import PredictionService

def test_prediction():
    print("=" * 80)
    print("TEST PREDICTION SERVICE")
    print("=" * 80)

    # Load model
    model_path = Path(__file__).parent.parent / "model" / "model_v2.pkl"
    print(f"\n[1] Loading model from: {model_path}")
    print(f"    Model exists: {model_path.exists()}")

    model = joblib.load(model_path)
    print(f"    [OK] Model loaded")
    print(f"    Model keys: {list(model.keys())}")
    print(f"    ORB n_features: {model.get('orb_n_features', 'N/A')}")
    print(f"    Vocab size: {model.get('vocab_size', 'N/A')}")
    print(f"    KMeans model: {type(model['kmeans_model']).__name__}")
    print(f"    XGBoost model: {type(model['xgb_model']).__name__}")

    # Initialize services
    print(f"\n[2] Initializing services...")
    image_preprocessor = ImagePreprocessorV2()
    prediction_service = PredictionService(model)
    print(f"    [OK] Services initialized")

    # Test with real image from dataset
    print(f"\n[3] Loading test image...")
    # Try to find a real image in the dataset
    dataset_path = Path(__file__).parent / "dataset"
    image_files = list(dataset_path.glob("**/*.jpg")) + list(dataset_path.glob("**/*.png"))

    if image_files:
        test_image_path = image_files[0]
        test_image = Image.open(test_image_path).convert('RGB')
        print(f"    [OK] Test image loaded: {test_image_path.name}")
    else:
        print(f"    [WARN] No dataset images found, creating dummy image")
        # Create a larger image (at least 128x128 for HOG feature extraction)
        import numpy as np
        img_array = np.random.randint(0, 256, (256, 256, 3), dtype=np.uint8)
        test_image = Image.fromarray(img_array, 'RGB')

    print(f"    Image size: {test_image.size}, mode: {test_image.mode}")

    # Preprocess image
    print(f"\n[4] Preprocessing image...")
    features = image_preprocessor.preprocess(test_image)
    print(f"    [OK] Features extracted")
    print(f"    Feature shape: {features.shape}")
    print(f"    Feature range: [{features.min():.4f}, {features.max():.4f}]")
    print(f"    Sample features: {features[0][:5]}")

    # Predict
    print(f"\n[5] Running prediction...")
    result = prediction_service.predict(features)
    print(f"    [OK] Prediction complete")
    print(f"    Waste class: {result.get('waste_class', 'N/A')}")
    print(f"    Waste type: {result.get('waste_type', 'N/A')}")
    print(f"    Category: {result.get('category', 'N/A')}")
    print(f"    Confidence: {result.get('confidence', 0):.2f}%")

    # Format response
    print(f"\n[6] Formatting response...")
    response = prediction_service.format_response(result)
    print(f"    [OK] Response formatted")
    print(f"\n    Response structure:")
    print(f"    - success: {response['success']}")
    if 'data' in response:
        print(f"    - wasteType: {response['data'].get('wasteType', 'N/A')}")
        print(f"    - category: {response['data'].get('category', 'N/A')}")
        print(f"    - confidence: {response['data'].get('confidence', 0)}%")
        print(f"    - tips count: {len(response['data'].get('tips', []))}")
        print(f"    - description: {response['data'].get('description', 'N/A')}")

        if 'modelInfo' in response['data'] and 'probabilitiesPerClass' in response['data']['modelInfo']:
            print(f"\n    Probabilities per class:")
            for waste_name, prob_data in response['data']['modelInfo']['probabilitiesPerClass'].items():
                if isinstance(prob_data, dict):
                    print(f"      {waste_name}: {prob_data.get('probability', 0):.2f}% -> {prob_data.get('category', 'N/A')}")
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
