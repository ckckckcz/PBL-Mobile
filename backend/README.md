---
title: Pilar API
emoji: ♻️
colorFrom: green
colorTo: blue
sdk: docker
app_file: Dockerfile
pinned: false
---

# Pilar API – Hugging Face Space

API untuk klasifikasi jenis sampah menggunakan model XGBoost hybrid. Repository ini telah dikonfigurasi agar dapat dijalankan sebagai Hugging Face Space berbasis Docker maupun secara lokal.

## 🚀 Fitur Utama

- **FastAPI** dengan middleware logging yang mendetail.
- **ModelService** + **PredictionService** yang memuat model `xgb_model.json` dan `artifacts.pkl`.
- Konfigurasi otomatis `HOST` dan `PORT` mengikuti variabel lingkungan Hugging Face.
- Dockerfile ringan berbasis `python:3.10-slim` dengan dependensi yang diperlukan.

## 📦 Struktur Direktori (ringkas)

- `app/`
  - `main.py` – entry point FastAPI.
  - `services/` – pemuatan model dan prediksi.
  - `api/` – router `health` dan `predict`.
- `model/`
  - `xgb_model.json`, `artifacts.pkl`, dan aset pendukung.
- `requirements.txt`
- `Dockerfile`
- `index.py` (opsional untuk Vercel)

## 🧱 Konfigurasi Hugging Face Space

Tidak diperlukan penyesuaian tambahan—Spaces akan mem-build image menggunakan `Dockerfile` dan menjalankan perintah:
```
uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-7860}
```

Catatan penting:
- `HOST` default `0.0.0.0`.
- Port otomatis diatur oleh platform (`PORT`, `HF_PORT`, atau `SPACE_PORT`).

## ⚙️ Environment Variables

| Variabel | Deskripsi | Default |
|----------|-----------|---------|
| `APP_MODE` | `demo` atau `production`. Mode `demo` nonaktifkan Supabase/auth. | `demo` |
| `HOST` | Host binding FastAPI. | `0.0.0.0` |
| `PORT` / `HF_PORT` / `SPACE_PORT` | Port runtime (dipilih otomatis oleh HF). | `7860` |
| Variabel lainnya | (opsional) kredensial Supabase, JWT, dsb. | — |

## 🛠️ Pengembangan Lokal

1. **Persiapkan virtual env (opsional):**
   ```
   python -m venv .venv
   source .venv/bin/activate  # Linux/Mac
   .venv\Scripts\activate     # Windows
   ```

2. **Install dependensi:**
   ```
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

3. **Jalankan server:**
   ```
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

4. **Tes lokal cepat:**
   ```
   python test/test_local.py
   ```

## 🐳 Jalankan via Docker (Lokal)

```
docker build -t pilar-api .
docker run --rm -p 7860:7860 \
    -e PORT=7860 \
    pilar-api
```

API akan tersedia pada `http://localhost:7860`.

## 🔍 Endpoint Utama

- `GET /health` – status API.
- `POST /predict` – klasifikasi sampah (butuh payload numerik 38 fitur). Contoh payload dapat dilihat di `test/test_predict.py`.

## 📄 Lisensi

Proyek ini dimaksudkan untuk kebutuhan internal akademik/tugas akhir. Silakan sesuaikan lisensi sesuai kebutuhan jika akan dipublikasikan lebih luas.

Selamat mencoba! Jangan ragu menyesuaikan konfigurasi untuk kebutuhan khusus lainnya.