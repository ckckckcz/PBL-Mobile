/// App string constants
/// Centralized string management for easy localization and consistency
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // App Info
  static const String appName = 'PILAR Apps';
  static const String appVersion = 'Versi 1.0';
  static const String developer = 'Developed by Kelompok 04';
  static const String appTagline = 'Pilah Sampah dengan Cerdas';

  // Navigation
  static const String navHome = 'Beranda';
  static const String navScan = 'Pindai';
  static const String navHistory = 'Riwayat';
  static const String navProfile = 'Profil';

  // Auth Strings
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Nama Lengkap';
  static const String phone = 'Nomor Telepon';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String forgotPassword = 'Lupa Password?';
  static const String rememberMe = 'Ingat Saya';
  static const String dontHaveAccount = 'Belum punya akun?';
  static const String alreadyHaveAccount = 'Sudah punya akun?';
  static const String registerHere = 'Daftar di sini';
  static const String loginHere = 'Masuk di sini';

  // Scan Strings
  static const String scanTitle = 'Pindai Sampah';
  static const String scanInstruction = 'Arahkan kamera ke sampah';
  static const String scanButton = 'Ambil Foto';
  static const String scanFromGallery = 'Pilih dari Galeri';
  static const String scanning = 'Memindai...';
  static const String analyzing = 'Menganalisis gambar...';
  static const String flashOn = 'Flash Aktif';
  static const String flashOff = 'Flash Mati';
  static const String rescan = 'Pindai Ulang';

  // Result Strings
  static const String resultTitle = 'Hasil Pemindaian';
  static const String wasteType = 'Jenis Sampah';
  static const String category = 'Kategori';
  static const String confidence = 'Tingkat Kepercayaan';
  static const String description = 'Deskripsi';
  static const String tips = 'Tips Pengelolaan';
  static const String tipsTitle = 'Tips Pengelolaan';
  static const String unknownWaste = 'Jenis Sampah Tidak Diketahui';
  static const String noDescription = 'Tidak ada deskripsi tersedia';

  // History Strings
  static const String history = 'Riwayat';
  static const String historyEmpty = 'Belum Ada Riwayat';
  static const String historyEmptyDesc =
      'Mulai pindai sampah untuk melihat riwayat di sini';
  static const String deleteHistory = 'Hapus Riwayat';
  static const String deleteHistoryConfirm =
      'Apakah Anda yakin ingin menghapus riwayat ini?';
  static const String clearAllHistory = 'Hapus Semua Riwayat';
  static const String clearAllHistoryConfirm =
      'Apakah Anda yakin ingin menghapus semua riwayat? Tindakan ini tidak dapat dibatalkan.';
  static const String deleteAll = 'Hapus Semua';
  static const String historyDeleted = 'Riwayat berhasil dihapus';
  static const String allHistoryDeleted = 'Semua riwayat berhasil dihapus';

  // Profile Strings
  static const String profile = 'Profil';
  static const String editProfile = 'Edit Profil';
  static const String changePassword = 'Ubah Password';
  static const String settings = 'Pengaturan';
  static const String aboutApp = 'Tentang Aplikasi';
  static const String helpCenter = 'Pusat Bantuan';
  static const String termsConditions = 'Syarat & Ketentuan';
  static const String privacyPolicy = 'Kebijakan Privasi';

  // Common Strings
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String back = 'Kembali';
  static const String next = 'Selanjutnya';
  static const String done = 'Selesai';
  static const String ok = 'OK';
  static const String yes = 'Ya';
  static const String no = 'Tidak';
  static const String retry = 'Coba Lagi';
  static const String loading = 'Memuat...';
  static const String pleaseWait = 'Mohon tunggu...';
  static const String noData = 'Tidak ada data';
  static const String noInternet = 'Tidak ada koneksi internet';

  // Validation Messages
  static const String emailRequired = 'Email harus diisi';
  static const String emailInvalid = 'Format email tidak valid';
  static const String passwordRequired = 'Password harus diisi';
  static const String passwordMinLength = 'Password minimal 6 karakter';
  static const String passwordMismatch = 'Password tidak cocok';
  static const String nameRequired = 'Nama harus diisi';
  static const String phoneInvalid = 'Format nomor telepon tidak valid';

  // Error Messages
  static const String errorGeneric = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork =
      'Gagal terhubung ke server. Periksa koneksi internet Anda.';
  static const String errorLogin =
      'Login gagal. Periksa email dan password Anda.';
  static const String errorRegister = 'Registrasi gagal. Silakan coba lagi.';
  static const String errorLoadImage = 'Gagal memuat gambar';
  static const String errorTakePhoto = 'Gagal mengambil foto';
  static const String errorPickImage = 'Gagal memilih gambar';
  static const String errorPrediction = 'Gagal menganalisis gambar';
  static const String errorCameraPermission =
      'Izin kamera diperlukan untuk menggunakan fitur scan';
  static const String errorStoragePermission =
      'Izin storage diperlukan untuk mengakses galeri';
  static const String errorPhotoPermission =
      'Izin akses foto diperlukan untuk mengakses galeri';
  static const String cameraNotAvailable =
      'Kamera tidak tersedia. Silakan gunakan galeri.';
  static const String cameraNotReady = 'Kamera belum siap';

  // Success Messages
  static const String loginSuccess = 'Login berhasil';
  static const String registerSuccess = 'Registrasi berhasil. Selamat datang!';
  static const String logoutSuccess = 'Logout berhasil';
  static const String saveSuccess = 'Data berhasil disimpan';
  static const String updateSuccess = 'Data berhasil diperbarui';
  static const String deleteSuccess = 'Data berhasil dihapus';

  // Category Names
  static const String categoryOrganic = 'Organik';
  static const String categoryInorganic = 'Anorganik';

  // Date Format
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    }
  }
}
