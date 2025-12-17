# Environment Variables Setup Guide

## File yang Perlu Ada

File `.env` harus ada di folder `backend/` dengan isi sebagai berikut:

```env
# Application Mode
# - "demo" = Mode demo tanpa database (tidak perlu Supabase)
# - "production" = Mode production dengan Supabase
APP_MODE=production

# Supabase Configuration (hanya diperlukan jika APP_MODE=production)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
```

## Cara Setup

### 1. Local Development

1. Copy file `.env.example` menjadi `.env`:
   ```bash
   cd backend
   cp .env.example .env
   ```

2. Edit file `.env` dan isi dengan nilai yang sesuai:
   - Untuk mode demo (tanpa database):
     ```env
     APP_MODE=demo
     ```
   
   - Untuk mode production (dengan Supabase):
     ```env
     APP_MODE=production
     SUPABASE_URL=https://xxxxx.supabase.co
     SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
     ```

3. Restart aplikasi agar environment variables terbaca

### 2. Hugging Face Spaces

**PENTING:** Jangan push file `.env` ke Git/Hugging Face!

Di Hugging Face Spaces, set environment variables lewat UI:

1. Buka Space Anda di Hugging Face
2. Klik tab **"Settings"**
3. Scroll ke **"Variables and secrets"**
4. Tambahkan variables berikut:

   **Public Variables:**
   - Name: `APP_MODE`
   - Value: `production`

   **Secrets:**
   - Name: `SUPABASE_URL`
   - Value: `https://xxxxx.supabase.co`
   
   - Name: `SUPABASE_KEY`
   - Value: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

5. **RESTART** Space Anda (stop → start) agar env vars terbaca

### 3. Vercel/Railway/Render

Set environment variables di dashboard masing-masing platform:

- **Vercel:** Project Settings → Environment Variables
- **Railway:** Project → Variables
- **Render:** Environment → Environment Variables

## Cara Mendapatkan Supabase Credentials

1. Login ke [supabase.com](https://supabase.com)
2. Pilih/buat project Anda
3. Klik **Settings** (icon gear) di sidebar
4. Klik **API** di menu Settings
5. Copy nilai berikut:
   - **Project URL** → untuk `SUPABASE_URL`
   - **Project API keys → anon/public** → untuk `SUPABASE_KEY`

## Troubleshooting

### Error: 404 pada endpoint `/api/auth/login`

**Penyebab:** `APP_MODE` tidak di-set atau masih `demo`

**Solusi:**
1. Pastikan `APP_MODE=production` di environment variables
2. Restart aplikasi/Space
3. Cek log startup, harus ada:
   ```
   app_mode: production
   Production routers enabled
   ```

### Error: `SUPABASE_URL` atau `SUPABASE_KEY` None

**Penyebab:** Environment variables tidak terbaca

**Solusi:**
1. **Local:** Pastikan file `.env` ada di `backend/` dan berisi nilai yang benar
2. **Hosted:** Pastikan environment variables sudah di-set di platform dan sudah restart
3. **Hugging Face:** Pastikan Secrets sudah disimpan (bukan Variables biasa)

### Mode Demo vs Production

| Feature | Demo Mode | Production Mode |
|---------|-----------|-----------------|
| Auth endpoints (`/api/auth/*`) | ❌ Disabled (404) | ✅ Enabled |
| User management | ❌ Disabled | ✅ Enabled |
| Database (Supabase) | ❌ Not used | ✅ Required |
| Model prediction | ✅ Works | ✅ Works |
| Dashboard | ✅ Works | ✅ Works |

## Contoh Log Startup yang Benar

### Demo Mode:
```
[DATABASE] ⚠️  Running in DEMO mode - Supabase disabled
app_mode: demo
Demo mode - routers disabled
```

### Production Mode:
```
[DATABASE] ✓ Supabase client initialized successfully
app_mode: production
Production routers enabled
```

## Checklist Setup Hugging Face Space

- [ ] Space sudah dibuat di Hugging Face
- [ ] Code sudah di-push ke repository
- [ ] Environment variable `APP_MODE=production` sudah ditambahkan
- [ ] Secret `SUPABASE_URL` sudah ditambahkan
- [ ] Secret `SUPABASE_KEY` sudah ditambahkan
- [ ] Space sudah di-restart (stop → start)
- [ ] Cek log startup untuk konfirmasi "Production routers enabled"
- [ ] Test endpoint `/api/auth/login` (seharusnya tidak 404)
- [ ] Test dashboard di `/` (seharusnya bisa akses)

## File Config yang Digunakan

✅ **File yang DIPAKAI:**
- `backend/app/core/config.py` - Config utama (dengan `load_dotenv()`)

❌ **File yang DIHAPUS:**
- `backend/app/config.py` - Duplikat yang menyebabkan konflik

Semua import harus menggunakan:
```python
from app.core.config import APP_MODE, SUPABASE_URL, SUPABASE_KEY
```

atau (jika dari dalam app/):
```python
from .core.config import APP_MODE, SUPABASE_URL, SUPABASE_KEY
```
