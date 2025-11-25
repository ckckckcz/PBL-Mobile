# Trash Detection Backend API

Backend API untuk deteksi jenis sampah menggunakan FastAPI dan machine learning model.

## 🚀 Fitur

- ✅ Prediksi jenis sampah dari gambar (Organik, Anorganik, B3)
- ✅ Load model machine learning otomatis saat startup
- ✅ RESTful API endpoints
- ✅ CORS support untuk React Native
- ✅ Health check endpoint
- ✅ Tips pengolahan sampah berdasarkan kategori

## 📋 Requirements

- Python 3.8+
- FastAPI
- Uvicorn
- Pillow (PIL)
- NumPy
- scikit-learn
- Supabase (opsional)

## 🔧 Instalasi

1. **Clone repository dan masuk ke folder backend**
```bash
cd trash-detection/backend
```

2. **Buat virtual environment (opsional tapi direkomendasikan)**
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

3. **Install dependencies**
```bash
pip install fastapi uvicorn python-multipart Pillow numpy scikit-learn supabase
```

4. **Setup environment variables**
Buat file `.env` atau update `app/config.py` dengan Supabase credentials Anda:
```python
SUPABASE_URL = "your_supabase_url"
SUPABASE_KEY = "your_supabase_key"
```

## 🎯 Menjalankan Server

### Cara 1: Menggunakan run.py
```bash
python run.py
```

### Cara 2: Menggunakan uvicorn langsung
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Server akan berjalan di: `http://localhost:8000`

## 📡 API Endpoints

### 1. Root Endpoint
```http
GET /
```

**Response:**
```json
{
  "message": "Trash Detection API is ready!",
  "model_loaded": true,
  "endpoints": {
    "predict": "/api/predict",
    "health": "/health"
  }
}
```

### 2. Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

### 3. Predict Waste (Main Endpoint)
```http
POST /api/predict
```

**Request:**
- Content-Type: `multipart/form-data`
- Body: `file` (image file)

**Response:**
```json
{
  "success": true,
  "data": {
    "wasteType": "Botol Plastik",
    "category": "Sampah Anorganik",
    "confidence": 95.5,
    "tips": [
      {
        "title": "Bersihkan sampah anorganik sebelum dibuang",
        "color": "#4DB8AC"
      },
      {
        "title": "Pisahkan plastik, kaca, dan logam",
        "color": "#F59E0B"
      }
    ],
    "description": "Botol Plastik termasuk dalam kategori Sampah Anorganik"
  }
}
```

### 4. Get Users (Supabase Example)
```http
GET /users
```

**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

## 🧪 Testing dengan cURL

### Test Health Check
```bash
curl http://localhost:8000/health
```

### Test Prediction
```bash
curl -X POST "http://localhost:8000/api/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/your/image.jpg"
```

## 🔍 Kategori Sampah

API dapat mendeteksi 3 kategori sampah:

1. **Sampah Organik**
   - Sisa makanan
   - Daun-daunan
   - Material biodegradable

2. **Sampah Anorganik**
   - Plastik
   - Botol
   - Kaleng
   - Kertas
   - Kaca

3. **Sampah B3 (Bahan Berbahaya dan Beracun)**
   - Baterai
   - Elektronik
   - Material medis

## 📱 Integrasi dengan Frontend

Untuk mengakses API dari React Native:

1. **Android Emulator:** `http://10.0.2.2:8000`
2. **iOS Simulator:** `http://localhost:8000`
3. **Physical Device:** `http://<YOUR_LOCAL_IP>:8000`

Contoh menggunakan fetch:
```typescript
const formData = new FormData();
formData.append('file', {
  uri: imageUri,
  name: 'photo.jpg',
  type: 'image/jpeg',
});

const response = await fetch('http://10.0.2.2:8000/api/predict', {
  method: 'POST',
  body: formData,
});

const result = await response.json();
```

## 🛠️ Development

### Struktur Project
```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py          # Main FastAPI application
│   └── config.py        # Configuration
├── model/
│   └── model_sampah_hybrid_final.pkl  # ML Model
├── run.py               # Server runner
└── README.md
```

### Menambah Kategori Sampah Baru

Edit file `app/main.py` di bagian `WASTE_TIPS`:

```python
WASTE_TIPS = {
    "Kategori Baru": [
        {
            "title": "Tip 1",
            "color": "#4DB8AC"
        },
        # ... tips lainnya
    ]
}
```

## 🐛 Troubleshooting

### Model tidak ter-load
```
Error: Model belum dimuat
```
**Solusi:** Pastikan file `model/model_sampah_hybrid_final.pkl` ada dan valid

### CORS Error dari frontend
**Solusi:** Pastikan CORS middleware sudah diaktifkan di `main.py` (sudah aktif secara default)

### Connection refused
**Solusi:** 
- Pastikan server berjalan di `0.0.0.0:8000`
- Cek firewall
- Gunakan IP yang tepat untuk device/emulator

### Image preprocessing error
**Solusi:** Pastikan gambar dalam format yang supported (JPG, PNG)

## 📝 Logs

Server akan menampilkan log untuk setiap request:
```
INFO:     127.0.0.1:52470 - "POST /api/predict HTTP/1.1" 200 OK
INFO:app.main:Prediction successful: Botol Plastik with 95.5% confidence
```

## 🚀 Production Deployment

Untuk production, gunakan:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

Atau gunakan Gunicorn:
```bash
pip install gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 📄 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.