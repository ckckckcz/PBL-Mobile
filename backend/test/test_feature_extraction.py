"""
Test script for 38-feature extraction
Verify that feature extraction produces correct output matching training notebook
"""

import sys
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent))

import numpy as np
from app.services.image_service import get_image_preprocessor
from PIL import Image
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def test_feature_extraction():
    """Test feature extraction with a sample image"""

    print("=" * 60)
    print("TESTING 38-FEATURE EXTRACTION")
    print("=" * 60)
    print()

    # Create preprocessor
    print("[1/5] Initializing ImagePreprocessor...")
    preprocessor = get_image_preprocessor()
    print(f"   ✓ Target size: {preprocessor.target_size}")
    print(f"   ✓ Expected features: {preprocessor.n_features}")
    print()

    # Test with dummy image
    print("[2/5] Creating test image (128x128 RGB)...")
    test_image = np.random.randint(0, 255, (128, 128, 3), dtype=np.uint8)
    pil_image = Image.fromarray(test_image)
    print(f"   ✓ Test image shape: {test_image.shape}")
    print()

    # Extract features
    print("[3/5] Extracting features...")
    try:
        features = preprocessor.extract_features(pil_image)
        print(f"   ✓ Features extracted successfully")
        print()
    except Exception as e:
        print(f"   ✗ Feature extraction failed: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Validate features
    print("[4/5] Validating features...")
    print(f"   - Shape: {features.shape}")
    print(f"   - Expected: (1, 38)")
    print(f"   - Match: {features.shape == (1, 38)}")
    print()

    print(f"   - Data type: {features.dtype}")
    print(f"   - Expected: float32")
    print(f"   - Match: {features.dtype == np.float32}")
    print()

    print(f"   - Min value: {features.min():.6f}")
    print(f"   - Max value: {features.max():.6f}")
    print(f"   - Mean value: {features.mean():.6f}")
    print(f"   - Std value: {features.std():.6f}")
    print()

    # Check for invalid values
    has_nan = np.isnan(features).any()
    has_inf = np.isinf(features).any()
    print(f"   - Contains NaN: {has_nan}")
    print(f"   - Contains Inf: {has_inf}")
    print()

    # Feature breakdown
    print("[5/5] Feature breakdown (expected composition):")
    print("   - Features [0:24]   : HSV Histogram (24)")
    print("   - Features [24:29]  : GLCM Texture (5)")
    print("   - Features [29:31]  : HOG (2)")
    print("   - Features [31:34]  : Canny Edges (3)")
    print("   - Features [34:36]  : Laplacian (2)")
    print("   - Features [36:38]  : Reflection (2)")
    print()

    # Sample values from each group
    print("   Sample values:")
    print(f"   - HSV[0]: {features[0, 0]:.6f}")
    print(f"   - GLCM[24]: {features[0, 24]:.6f}")
    print(f"   - HOG[29]: {features[0, 29]:.6f}")
    print(f"   - Canny[31]: {features[0, 31]:.6f}")
    print(f"   - Laplacian[34]: {features[0, 34]:.6f}")
    print(f"   - Reflection[36]: {features[0, 36]:.6f}")
    print()

    # Test different input types
    print("[BONUS] Testing different input types...")
    print("   - Testing PIL Image... ", end="")
    try:
        f1 = preprocessor.preprocess(pil_image)
        print(f"✓ Shape: {f1.shape}")
    except Exception as e:
        print(f"✗ Failed: {e}")

    print("   - Testing numpy array... ", end="")
    try:
        f2 = preprocessor.preprocess(test_image)
        print(f"✓ Shape: {f2.shape}")
    except Exception as e:
        print(f"✗ Failed: {e}")

    print("   - Testing bytes... ", end="")
    try:
        import io
        buf = io.BytesIO()
        pil_image.save(buf, format='PNG')
        image_bytes = buf.getvalue()
        f3 = preprocessor.preprocess(image_bytes)
        print(f"✓ Shape: {f3.shape}")
    except Exception as e:
        print(f"✗ Failed: {e}")

    print()

    # Final verdict
    print("=" * 60)
    if features.shape == (1, 38) and not has_nan and not has_inf:
        print("✓ ALL TESTS PASSED")
        print("Feature extraction is working correctly!")
        print("Ready for production predictions.")
    else:
        print("✗ TESTS FAILED")
        print("Please check the errors above.")
        return False
    print("=" * 60)
    print()

    return True


def test_with_real_image(image_path):
    """Test with a real image file if provided"""

    print("=" * 60)
    print(f"TESTING WITH REAL IMAGE: {image_path}")
    print("=" * 60)
    print()

    if not Path(image_path).exists():
        print(f"✗ Image not found: {image_path}")
        return False

    preprocessor = get_image_preprocessor()

    try:
        # Load image
        print("[1/3] Loading image...")
        img = Image.open(image_path)
        print(f"   ✓ Image size: {img.size}")
        print(f"   ✓ Image mode: {img.mode}")
        print()

        # Extract features
        print("[2/3] Extracting features...")
        features = preprocessor.preprocess(img)
        print(f"   ✓ Features shape: {features.shape}")
        print(f"   ✓ Features dtype: {features.dtype}")
        print()

        # Show statistics
        print("[3/3] Feature statistics:")
        print(f"   - Min: {features.min():.6f}")
        print(f"   - Max: {features.max():.6f}")
        print(f"   - Mean: {features.mean():.6f}")
        print(f"   - Std: {features.std():.6f}")
        print()

        print("=" * 60)
        print("✓ REAL IMAGE TEST PASSED")
        print("=" * 60)
        print()

        return True

    except Exception as e:
        print(f"✗ Test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("\n")
    print("╔" + "=" * 58 + "╗")
    print("║" + " " * 10 + "38-FEATURE EXTRACTION TEST" + " " * 22 + "║")
    print("╚" + "=" * 58 + "╝")
    print()

    # Run basic test
    success = test_feature_extraction()

    # Test with real image if provided
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        print("\n")
        success = test_with_real_image(image_path) and success

    # Exit with appropriate code
    sys.exit(0 if success else 1)
