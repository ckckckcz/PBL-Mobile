-- ================================================================================
-- SUPABASE DATABASE SETUP - PBL MOBILE APP
-- ================================================================================
-- Tabel untuk menyimpan data users aplikasi
-- Database: Supabase PostgreSQL
-- Created: 2024
-- ================================================================================

-- Drop table jika sudah ada (hati-hati di production!)
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.scan_history CASCADE;

-- ================================================================================
-- TABLE: users
-- ================================================================================
-- Menyimpan data user untuk authentication dan profile
CREATE TABLE public.users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,

    -- Constraints
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT phone_format CHECK (phone IS NULL OR phone ~* '^\+?[0-9]{10,15}$')
);

-- ================================================================================
-- TABLE: scan_history
-- ================================================================================
-- Menyimpan riwayat scan sampah oleh user
CREATE TABLE public.scan_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    waste_category VARCHAR(50) NOT NULL, -- Sampah Organik, Sampah Anorganik, Sampah B3
    confidence DECIMAL(5,2) NOT NULL, -- 0.00 - 100.00
    tips JSONB, -- Array of tips dalam format JSON
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT waste_category_check CHECK (waste_category IN ('Sampah Organik', 'Sampah Anorganik', 'Sampah B3')),
    CONSTRAINT confidence_range CHECK (confidence >= 0 AND confidence <= 100)
);

-- ================================================================================
-- INDEXES untuk performance
-- ================================================================================
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_created_at ON public.users(created_at DESC);
CREATE INDEX idx_scan_history_user_id ON public.scan_history(user_id);
CREATE INDEX idx_scan_history_created_at ON public.scan_history(created_at DESC);
CREATE INDEX idx_scan_history_category ON public.scan_history(waste_category);

-- ================================================================================
-- FUNCTION: Update timestamp otomatis
-- ================================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk auto-update updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================================================
-- ROW LEVEL SECURITY (RLS)
-- ================================================================================
-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users dapat melihat dan mengupdate data mereka sendiri
CREATE POLICY "Users can view own data" ON public.users
    FOR SELECT
    USING (true); -- Sementara allow all untuk development

CREATE POLICY "Users can insert during registration" ON public.users
    FOR INSERT
    WITH CHECK (true); -- Allow registration untuk user baru

CREATE POLICY "Users can update own data" ON public.users
    FOR UPDATE
    USING (true);

-- Policy: Users dapat melihat scan history mereka sendiri
CREATE POLICY "Users can view own scan history" ON public.scan_history
    FOR SELECT
    USING (true);

CREATE POLICY "Users can insert own scan history" ON public.scan_history
    FOR INSERT
    WITH CHECK (true);

-- ================================================================================
-- SAMPLE DATA untuk testing
-- ================================================================================
-- Password untuk semua sample user: "password123"
-- Hash menggunakan bcrypt dengan cost=12
-- Hash: $2b$12$lCu2ZtRKleZ9HQw0LErqYObr1aiigqDjOYTgNnTJnDNjYOCCSqsta

-- Sample User 1 (ID akan otomatis = 1)
INSERT INTO public.users (email, password_hash, full_name, phone) VALUES
('admin@pilar.com', '$2b$12$lCu2ZtRKleZ9HQw0LErqYObr1aiigqDjOYTgNnTJnDNjYOCCSqsta', 'Admin PILAR', '+6281234567890');

-- Sample User 2 (ID akan otomatis = 2)
INSERT INTO public.users (email, password_hash, full_name, phone) VALUES
('user@pilar.com', '$2b$12$lCu2ZtRKleZ9HQw0LErqYObr1aiigqDjOYTgNnTJnDNjYOCCSqsta', 'User Testing', '+6281234567891');

-- Sample User 3 (ID akan otomatis = 3)
INSERT INTO public.users (email, password_hash, full_name) VALUES
('test@pilar.com', '$2b$12$lCu2ZtRKleZ9HQw0LErqYObr1aiigqDjOYTgNnTJnDNjYOCCSqsta', 'Test User');

-- ================================================================================
-- VIEWS untuk reporting (opsional)
-- ================================================================================
CREATE OR REPLACE VIEW user_statistics AS
SELECT
    u.id,
    u.email,
    u.full_name,
    COUNT(sh.id) as total_scans,
    COUNT(CASE WHEN sh.waste_category = 'Sampah Organik' THEN 1 END) as organic_scans,
    COUNT(CASE WHEN sh.waste_category = 'Sampah Anorganik' THEN 1 END) as inorganic_scans,
    COUNT(CASE WHEN sh.waste_category = 'Sampah B3' THEN 1 END) as b3_scans,
    MAX(sh.created_at) as last_scan_at
FROM public.users u
LEFT JOIN public.scan_history sh ON u.id = sh.user_id
GROUP BY u.id, u.email, u.full_name;

-- ================================================================================
-- GRANTS untuk service role (Supabase akan handle ini otomatis)
-- ================================================================================
GRANT ALL ON public.users TO service_role;
GRANT ALL ON public.scan_history TO service_role;
GRANT SELECT ON user_statistics TO service_role;

-- Grant untuk sequences (diperlukan agar auto-increment berfungsi)
GRANT USAGE, SELECT ON SEQUENCE public.users_id_seq TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.scan_history_id_seq TO service_role;

-- ================================================================================
-- NOTES:
-- ================================================================================
-- 1. ID sekarang menggunakan SERIAL (auto-increment: 1, 2, 3, dst)
-- 2. Password hash menggunakan bcrypt dengan cost 12
-- 3. Sample password untuk testing: "password123"
-- 4. RLS policies sementara allow all untuk development
-- 5. Untuk production, sesuaikan RLS policies dengan auth.uid()
-- 6. Email format divalidasi dengan regex
-- 7. Phone format divalidasi (optional field)
-- 8. Confidence range 0-100
-- 9. Waste category hanya 3 pilihan
--
-- CARA PENGGUNAAN DI SUPABASE:
-- 1. Login ke https://app.supabase.com
-- 2. Pilih project Anda
-- 3. Klik "SQL Editor" di sidebar
-- 4. Copy-paste script ini
-- 5. Klik "Run" untuk execute
-- 6. Cek di "Table Editor" untuk melihat tabel yang dibuat
--
-- CARA TEST LOGIN:
-- Email: admin@pilar.com
-- Password: password123
