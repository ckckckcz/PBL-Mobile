"""
Local test script – aligned with XGB JSON + artifacts.pkl architecture
"""

import sys
from pathlib import Path
import logging

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parents[1]
MODEL_DIR = BASE_DIR / "model"


# ---------- TEST 1: FILE EXISTENCE ----------

def test_model_files_exist():
    logger.info("=" * 60)
    logger.info("TEST 1: Checking model files")
    logger.info("=" * 60)

    ok = True

    xgb = MODEL_DIR / "xgb_model.json"
    art = MODEL_DIR / "artifacts.pkl"

    if xgb.exists():
        logger.info(f"✅ XGB model: {xgb}")
    else:
        logger.error(f"❌ Missing: {xgb}")
        ok = False

    if art.exists():
        size_kb = art.stat().st_size / 1024
        logger.info(f"✅ Artifacts: {art} ({size_kb:.1f} KB)")
    else:
        logger.error(f"❌ Missing: {art}")
        ok = False

    return ok


# ---------- TEST 2: MANUAL MODEL LOAD ----------

def test_manual_loading():
    logger.info("\n" + "=" * 60)
    logger.info("TEST 2: Manual model load")
    logger.info("=" * 60)

    try:
        from xgboost import XGBClassifier
        import joblib

        xgb = XGBClassifier()
        xgb.load_model(str(MODEL_DIR / "xgb_model.json"))

        logger.info("✅ XGBoost JSON loaded")

        artifacts = joblib.load(MODEL_DIR / "artifacts.pkl")

        if not isinstance(artifacts, dict):
            logger.error(f"❌ Artifacts not dict: {type(artifacts)}")
            return False

        logger.info(f"✅ Artifact keys: {list(artifacts.keys())}")

        return True

    except Exception as e:
        logger.error(f"❌ Manual load failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


# ---------- TEST 3: DEP CHECK ----------

def test_dependencies():
    logger.info("\n" + "=" * 60)
    logger.info("TEST 3: Dependencies")
    logger.info("=" * 60)

    pkgs = ["fastapi", "uvicorn", "numpy", "xgboost", "joblib", "sklearn", "PIL"]

    ok = True

    for p in pkgs:
        try:
            __import__(p)
            logger.info(f"✅ {p}")
        except:
            logger.error(f"❌ {p} MISSING")
            ok = False

    return ok


# ---------- TEST 4: MODEL SERVICE ----------

def test_model_service():
    logger.info("\n" + "=" * 60)
    logger.info("TEST 4: ModelService")
    logger.info("=" * 60)

    try:
        sys.path.insert(0, str(BASE_DIR))

        from app.services.model_service import init_model_service

        service = init_model_service(base_dir=BASE_DIR)
        service.load_model()

        if not service.is_loaded():
            logger.error("❌ Service not loaded")
            return False

        info = service.get_model_info()

        logger.info("✅ Service ready")
        logger.info(f"✅ Source: {info['source']}")
        logger.info(f"✅ Components: {info['components']}")

        return True

    except Exception as e:
        logger.error(f"❌ ModelService failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


# ---------- TEST 5: PREDICTION ----------

def test_prediction():
    logger.info("\n" + "=" * 60)
    logger.info("TEST 5: Prediction")
    logger.info("=" * 60)

    try:
        import numpy as np
        sys.path.insert(0, str(BASE_DIR))

        from app.services.model_service import get_model_service, init_model_service
        from app.services.prediction_service import init_prediction_service

        service = get_model_service()

        if service is None:
            service = init_model_service(base_dir=BASE_DIR)
            service.load_model()

        model = service.get_model()
        ps = init_prediction_service(model)

        dummy = np.random.rand(1, 38).astype("float32")

        out = ps.predict(dummy)

        logger.info("✅ Prediction done")
        logger.info(f"✅ Type: {out['waste_type']}")
        logger.info(f"✅ Confidence: {out['confidence']}%")

        return True

    except Exception as e:
        logger.error(f"❌ Prediction failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False


# ---------- RUNNER ----------

def run_all():
    tests = [
        ("Files", test_model_files_exist),
        ("Manual Load", test_manual_loading),
        ("Deps", test_dependencies),
        ("ModelService", test_model_service),
        ("Prediction", test_prediction),
    ]

    passed = 0

    for name, fn in tests:
        ok = fn()
        if ok:
            passed += 1

    logger.info("\n" + "=" * 60)
    logger.info(f"✅ Passed: {passed}/{len(tests)}")


if __name__ == "__main__":
    run_all()
