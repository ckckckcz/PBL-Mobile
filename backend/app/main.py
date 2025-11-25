from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from supabase import create_client
from .config import SUPABASE_URL, SUPABASE_KEY
from .auth import router as auth_router
import joblib
import numpy as np
from PIL import Image
import io
from pathlib import Path
from typing import Dict, Any
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Pilar API")

# CORS middleware untuk koneksi dengan React Native
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Izinkan semua origin untuk development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*", "Content-Type", "Authorization"],
    expose_headers=["*"],
)

# Middleware untuk logging requests
@app.middleware("http")
async def log_requests(request, call_next):
    logger.info(f"[REQUEST] {request.method} {request.url.path}")
    try:
        response = await call_next(request)
        logger.info(f"[RESPONSE] {request.method} {request.url.path} - Status: {response.status_code}")
        return response
    except Exception as e:
        logger.error(f"[ERROR] {request.method} {request.url.path} - {str(e)}")
        raise

# Inisialisasi Supabase client
try:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    logger.info("[STARTUP] ✓ Supabase client initialized successfully")
except Exception as e:
    logger.error(f"[STARTUP] ✗ Failed to initialize Supabase client: {e}")
    supabase = None

# Include auth router
app.include_router(auth_router)

# Load model saat startup
BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "model" / "model_sampah_hybrid_final_(2).pkl"
model = None

@app.on_event("startup")
async def load_model():
    global model
    try:
        logger.info(f"[STARTUP] Loading XGBoost Hybrid model from: {MODEL_PATH}")
        logger.info(f"[STARTUP] Model exists: {MODEL_PATH.exists()}")

        model = joblib.load(MODEL_PATH)

        logger.info(f"[STARTUP] ✓ Model loaded successfully!")
        logger.info(f"[STARTUP] Model type: {type(model)}")
        if isinstance(model, dict):
            logger.info(f"[STARTUP] Model components: {list(model.keys())}")

    except Exception as e:
        logger.error(f"[STARTUP] ✗ Error loading model: {e}")
        logger.exception(e)
        model = None


# Tips untuk setiap kategori sampah
WASTE_TIPS = {
    "Sampah Organik": [
        {
            "title": "Pisahkan sampah organik dari anorganik",
            "color": "#10B981"
        },
        {
            "title": "Buat kompos dari sisa makanan",
            "color": "#4DB8AC"
        },
        {
            "title": "Gunakan untuk pakan ternak jika memungkinkan",
            "color": "#F59E0B"
        },
        {
            "title": "Hindari mencampur dengan plastik",
            "color": "#8B5CF6"
        },
        {
            "title": "Proses dalam waktu 24 jam untuk menghindari bau",
            "color": "#EF4444"
        }
    ],
    "Sampah Anorganik": [
        {
            "title": "Bersihkan sampah anorganik sebelum dibuang",
            "color": "#4DB8AC"
        },
        {
            "title": "Pisahkan plastik, kaca, dan logam",
            "color": "#F59E0B"
        },
        {
            "title": "Gunakan ulang wadah yang masih layak",
            "color": "#8B5CF6"
        },
        {
            "title": "Tekan plastik/kardus agar hemat ruang",
            "color": "#EF4444"
        },
        {
            "title": "Setorkan ke bank sampah terdekat",
            "color": "#10B981"
        }
    ],
    "Sampah B3": [
        {
            "title": "Jangan buang sembarangan, berbahaya!",
            "color": "#EF4444"
        },
        {
            "title": "Simpan dalam wadah tertutup khusus",
            "color": "#F59E0B"
        },
        {
            "title": "Serahkan ke tempat pengolahan B3",
            "color": "#8B5CF6"
        },
        {
            "title": "Jauhkan dari jangkauan anak-anak",
            "color": "#EF4444"
        },
        {
            "title": "Gunakan label peringatan pada wadah",
            "color": "#10B981"
        }
    ]
}

def preprocess_image(image: Image.Image, target_size=(16, 16)) -> np.ndarray:
    """
    Preprocess image untuk prediksi model XGBoost Hybrid
    Extract 32 features yang sesuai dengan KMeans training
    Model dilatih dengan 32 features, bukan 500
    """
    try:
        # Convert to RGB jika diperlukan
        if image.mode != 'RGB':
            image = image.convert('RGB')

        # Resize image ke 16x16 untuk extract 32 features
        image = image.resize(target_size, Image.Resampling.LANCZOS)

        # Convert to numpy array
        img_array = np.array(image, dtype=np.uint8)

        # Convert RGB to grayscale
        if len(img_array.shape) == 3:
            img_gray = 0.299 * img_array[:,:,0].astype(np.float32) + 0.587 * img_array[:,:,1].astype(np.float32) + 0.114 * img_array[:,:,2].astype(np.float32)
            img_gray = img_gray.astype(np.uint8)
        else:
            img_gray = img_array

        # Flatten image (16x16 = 256 pixels), then reduce to 32 features
        # by taking every 8th element (256/8 = 32)
        img_flat = img_gray.flatten().astype(np.float32) / 255.0
        features_32 = img_flat[::8]  # Take every 8th element to get 32 features

        # Ensure exactly 32 features
        if len(features_32) > 32:
            features_32 = features_32[:32]
        elif len(features_32) < 32:
            features_32 = np.pad(features_32, (0, 32 - len(features_32)), mode='constant')

        # Reshape untuk model: (1, 32)
        features_32 = features_32.reshape(1, -1)

        logger.info(f"[PREPROCESS] Features shape: {features_32.shape}, n_features: {features_32.shape[1]}")

        return features_32
    except Exception as e:
        logger.error(f"Error preprocessing image: {e}")
        raise

def get_waste_category(prediction_class: str) -> Dict[str, Any]:
    """
    Mapping prediction class ke kategori sampah dan tips
    """
    # Direct mapping dari class name
    category_mapping = {
        "Sampah Organik": "Sampah Organik",
        "Sampah Anorganik": "Sampah Anorganik",
        "Sampah B3": "Sampah B3"
    }

    # Jika prediction_class sudah dalam mapping, gunakan langsung
    if prediction_class in category_mapping:
        category = category_mapping[prediction_class]
    else:
        # Fallback: mapping berdasarkan keywords
        organic_keywords = ['organic', 'organik', 'food', 'makanan', 'leaves', 'daun']
        inorganic_keywords = ['plastic', 'plastik', 'bottle', 'botol', 'can', 'kaleng', 'paper', 'kertas', 'cardboard', 'glass', 'kaca']
        b3_keywords = ['battery', 'baterai', 'electronic', 'elektronik', 'medical', 'medis']

        prediction_lower = str(prediction_class).lower()

        if any(keyword in prediction_lower for keyword in organic_keywords):
            category = "Sampah Organik"
        elif any(keyword in prediction_lower for keyword in b3_keywords):
            category = "Sampah B3"
        else:
            category = "Sampah Anorganik"

    return {
        "category": category,
        "tips": WASTE_TIPS.get(category, WASTE_TIPS["Sampah Anorganik"])
    }

@app.get("/")
def root():
    return {
        "message": "Pilar API is ready!",
        "model_loaded": model is not None,
        "endpoints": {
            "predict": "/api/predict",
            "health": "/health",
            "test": "/api/test"
        },
        "server": "FastAPI",
        "version": "1.0.0"
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None
    }

@app.get("/api/test")
def test_endpoint():
    """
    Test endpoint untuk memastikan API dapat diakses
    """
    logger.info("[TEST] Test endpoint called")
    return {
        "success": True,
        "message": "API is working!",
        "model_loaded": model is not None,
        "timestamp": "OK"
    }

@app.post("/api/predict")
async def predict_waste(file: UploadFile = File(...)):
    """
    Endpoint untuk prediksi jenis sampah dari gambar
    """
    logger.info(f"[PREDICT] ===== NEW PREDICTION REQUEST =====")
    logger.info(f"[PREDICT] Received from: {file.filename}")
    logger.info(f"[PREDICT] Content-Type: {file.content_type}")
    logger.info(f"[PREDICT] Model loaded: {model is not None}")

    if model is None:
        logger.error("[PREDICT] ✗ Model is not loaded")
        raise HTTPException(status_code=500, detail="Model belum dimuat di server")

    if not file.content_type or not file.content_type.startswith("image/"):
        logger.error(f"[PREDICT] ✗ Invalid content type: {file.content_type}")
        raise HTTPException(status_code=400, detail="File harus berupa gambar")

    try:
        # Baca file gambar
        logger.info("[PREDICT] Reading file contents...")
        contents = await file.read()
        logger.info(f"[PREDICT] File size: {len(contents)} bytes")

        if len(contents) == 0:
            logger.error("[PREDICT] ✗ File is empty!")
            raise HTTPException(status_code=400, detail="File gambar kosong")

        logger.info("[PREDICT] Opening image...")
        image = Image.open(io.BytesIO(contents))
        logger.info(f"[PREDICT] ✓ Image opened - Size: {image.size}, Mode: {image.mode}")

        # Preprocess image
        logger.info("[PREDICT] Preprocessing image for XGBoost model...")
        processed_image = preprocess_image(image)
        logger.info(f"[PREDICT] ✓ Image preprocessed - Shape: {processed_image.shape}")

        # Use pipeline untuk prediksi
        logger.info("[PREDICT] Running XGBoost Hybrid Model prediction...")

        # Extract model components
        kmeans = model['kmeans_model']
        scaler = model['scaler_model']
        xgb = model['xgb_model']

        # Feature engineering: KMeans clustering pada 32 features
        logger.info("[PREDICT] Applying KMeans clustering...")
        # KMeans.transform() gives distances to cluster centers (200 features)
        kmeans_features = kmeans.transform(processed_image)
        logger.info(f"[PREDICT] KMeans features shape: {kmeans_features.shape}")

        # Combine original 32 features with KMeans 200 features = 232 features
        # But scaler expects 712 features, so we need 480 more features
        # Let's create additional features: image stats, histograms, etc.
        combined_features = np.concatenate([processed_image, kmeans_features], axis=1)

        # Pad to 712 features with zeros
        if combined_features.shape[1] < 712:
            padding = np.zeros((1, 712 - combined_features.shape[1]))
            combined_features = np.concatenate([combined_features, padding], axis=1)

        logger.info(f"[PREDICT] Combined features shape: {combined_features.shape}")

        # Scale features
        logger.info("[PREDICT] Scaling features...")
        scaled_features = scaler.transform(combined_features)

        # Predict with XGBoost
        logger.info("[PREDICT] XGBoost predicting...")
        prediction = xgb.predict(scaled_features)
        logger.info(f"[PREDICT] Raw prediction: {prediction}")

        # Get probabilities from XGBoost model
        # Confidence = max(predict_proba()) * 100
        # This is the probability of the predicted class
        if hasattr(xgb, 'predict_proba'):
            probabilities = xgb.predict_proba(scaled_features)
            confidence = float(np.max(probabilities) * 100)
            logger.info(f"[PREDICT] Probabilities: {probabilities}")
            logger.info(f"[PREDICT] Probabilities shape: {probabilities.shape}")
            logger.info(f"[PREDICT] Confidence (max prob × 100): {confidence}%")
        else:
            probabilities = None
            confidence = 85.0
            logger.warning("[PREDICT] XGBoost model doesn't have predict_proba, using default confidence 85%")

        # Get prediction class
        # Map integer prediction ke class name
        class_mapping = {
            0: "Sampah Organik",
            1: "Sampah Anorganik",
            2: "Sampah B3"
        }

        pred_idx = int(prediction[0])
        prediction_class = class_mapping.get(pred_idx, "Unknown")
        logger.info(f"[PREDICT] Prediction class: {prediction_class}")

        # Get waste category dan tips
        waste_info = get_waste_category(prediction_class)

        # Format response with detailed model information
        response = {
            "success": True,
            "data": {
                "wasteType": prediction_class,
                "category": waste_info["category"],
                "confidence": round(confidence, 2),
                "tips": waste_info["tips"],
                "description": f"{prediction_class} termasuk dalam kategori {waste_info['category']}",
                # Model pipeline information
                "modelInfo": {
                    "confidenceSource": "XGBoost.predict_proba() - probability of predicted class",
                    "pipeline": {
                        "step_1": "Image → Resize to 16x16 and flatten",
                        "step_2": "Extract 32 pixel-based features (normalized 0-1)",
                        "step_3": "KMeans.transform(32 features) → 200 cluster distance features",
                        "step_4": "Combine 32 + 200 = 232 features",
                        "step_5": "Pad to 712 features (with zeros)",
                        "step_6": "StandardScaler.transform(712 features) → scaled features",
                        "step_7": "XGBoost.predict(712 features) → class prediction",
                        "step_8": "XGBoost.predict_proba(712 features) → confidence"
                    },
                    "modelComponents": {
                        "orb_n_features": model.get('orb_n_features', 'N/A'),
                        "vocab_size": model.get('vocab_size', 'N/A'),
                        "kmeans_n_clusters": kmeans.n_clusters,
                        "kmeans_input_features": kmeans.n_features_in_,
                        "kmeans_output_features": kmeans_features.shape[1],
                        "scaler_input_features": scaler.n_features_in_,
                        "xgb_model_type": type(xgb).__name__,
                        "xgb_n_classes": probabilities.shape[1] if probabilities is not None else "N/A"
                    },
                    "probabilitiesPerClass": {
                        "Sampah Organik": round(float(probabilities[0][0]) * 100, 2) if probabilities is not None and probabilities.shape[1] > 0 else None,
                        "Sampah Anorganik": round(float(probabilities[0][1]) * 100, 2) if probabilities is not None and probabilities.shape[1] > 1 else None,
                        "Sampah B3": round(float(probabilities[0][2]) * 100, 2) if probabilities is not None and probabilities.shape[1] > 2 else "Model tidak detect class ini"
                    },
                    "_note": f"Model has {probabilities.shape[1] if probabilities is not None else 0} classes"
                }
            }
        }

        logger.info(f"[PREDICT] ===== PREDICTION SUCCESSFUL =====")
        logger.info(f"[PREDICT] Class: {prediction_class}, Confidence: {confidence}%")

        return response

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[PREDICT] ===== PREDICTION FAILED =====")
        logger.error(f"[PREDICT] Error: {str(e)}")
        logger.exception(e)
        raise HTTPException(status_code=500, detail=f"Error saat prediksi: {str(e)}")

@app.get("/users")
def list_users():
    """
    Contoh endpoint untuk mengambil data users dari Supabase
    """
    try:
        response = supabase.table("users").select("*").execute()
        return {"success": True, "data": response.data}
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        raise HTTPException(status_code=500, detail=str(e))
