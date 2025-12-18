"""
Constants for waste classification and tips
Model V2: Binary classification (Organik vs Anorganik)
"""

from typing import Dict, List, Any

# Tips untuk setiap kategori sampah
WASTE_TIPS: Dict[str, List[Dict[str, str]]] = {
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
            "title": "Pisahkan berdasarkan jenis material",
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
    ]
}

# Mapping numeric class predictions to category names
# XGBoost Model: 0 = Organik, 1 = Anorganik
CLASS_MAPPING: Dict[int, str] = {
    0: "Sampah Organik",
    1: "Sampah Anorganik",
}

# Category mapping untuk internal use
CATEGORY_MAPPING: Dict[str, str] = {
    "ORGANIK": "Sampah Organik",
    "ANORGANIK": "Sampah Anorganik",
    0: "Sampah Organik",
    1: "Sampah Anorganik",
}

# Keywords untuk kategori sampah (untuk debugging/logging)
ORGANIC_KEYWORDS = [
    'organic', 'organik', 'food', 'makanan', 'organic waste'
]
INORGANIC_KEYWORDS = [
    'inorganic', 'anorganik', 'inorganic waste'
]

# Model configuration
MODEL_CONFIG = {
    "n_classes": 2,
    "class_names": ["Organik", "Anorganik"],
    "binary_classification": True,
    "vocab_size": 200,
    "orb_n_features": 500,
    "image_features": 38,
}
