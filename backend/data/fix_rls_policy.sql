-- ================================================================================
-- FIX RLS POLICY - Allow User Registration
-- ================================================================================
-- Error: new row violates row-level security policy for table "users"
-- Solution: Add INSERT policy untuk allow registrasi user baru
-- ================================================================================

-- Drop existing INSERT policy jika ada
DROP POLICY IF EXISTS "Users can insert during registration" ON public.users;
DROP POLICY IF EXISTS "Enable insert for registration" ON public.users;

-- Create new INSERT policy yang allow registration
CREATE POLICY "Enable insert for registration" ON public.users
    FOR INSERT
    WITH CHECK (true);

-- ================================================================================
-- VERIFICATION
-- ================================================================================
-- Untuk memverifikasi policy sudah aktif, jalankan query ini:
--
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'users';
--
-- Harusnya muncul policy:
-- - "Users can view own data" (SELECT)
-- - "Enable insert for registration" (INSERT)
-- - "Users can update own data" (UPDATE)
-- ================================================================================

-- CARA PENGGUNAAN:
-- 1. Login ke https://app.supabase.com
-- 2. Pilih project Anda
-- 3. Klik "SQL Editor" di sidebar
-- 4. Copy-paste script ini
-- 5. Klik "Run" untuk execute
-- 6. Test register dari Flutter app
-- ================================================================================

-- NOTES:
-- - WITH CHECK (true) artinya semua user bisa insert (untuk registration)
-- - Untuk production, bisa diubah jadi lebih strict
-- - Contoh production policy:
--   WITH CHECK (auth.role() = 'anon' AND email IS NOT NULL)
-- ================================================================================
