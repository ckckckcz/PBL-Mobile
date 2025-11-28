"""
Constants for waste classification and tips
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

# Mapping prediction class ke kategori sampah
CLASS_MAPPING: Dict[int, str] = {
    0: "Sampah Organik",
    1: "Sampah Anorganik",
    2: "Sampah B3"
}

# Category mapping untuk fallback
CATEGORY_MAPPING: Dict[str, str] = {
    "Sampah Organik": "Sampah Organik",
    "Sampah Anorganik": "Sampah Anorganik",
    "Sampah B3": "Sampah B3"
}

# Keywords untuk kategori sampah
ORGANIC_KEYWORDS = ['organic', 'organik', 'food', 'makanan', 'leaves', 'daun']
INORGANIC_KEYWORDS = ['plastic', 'plastik', 'bottle', 'botol', 'can', 'kaleng',
                      'paper', 'kertas', 'cardboard', 'glass', 'kaca']
B3_KEYWORDS = ['battery', 'baterai', 'electronic', 'elektronik', 'medical', 'medis']
