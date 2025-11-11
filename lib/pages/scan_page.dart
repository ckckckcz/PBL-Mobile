import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _detectionResult;
  String? _confidence;
  bool _showResult = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _image = File(picked.path);
          _showResult = false;
          _detectionResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih gambar terlebih dahulu'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulasi proses deteksi AI (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi hasil deteksi (random)
    final results = [
      {'type': 'Sampah Organik 🌱', 'confidence': '95%', 'isOrganic': true},
      {'type': 'Sampah Anorganik ♻️', 'confidence': '92%', 'isOrganic': false},
    ];
    final randomResult = results[DateTime.now().second % 2];

    setState(() {
      _isProcessing = false;
      _detectionResult = randomResult['type'] as String;
      _confidence = randomResult['confidence'] as String;
      _showResult = true;
    });

    // Show result bottom sheet
    _showResultBottomSheet(
      randomResult['type'] as String,
      randomResult['confidence'] as String,
      randomResult['isOrganic'] as bool,
    );
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _detectionResult = null;
      _confidence = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isProcessing,
        message: 'Mendeteksi sampah... 🔍',
        child: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scan Sampah',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_image != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _clearImage,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error.withOpacity(0.1),
                            foregroundColor: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Info Card
                        EcoCard(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ambil foto atau unggah gambar untuk deteksi jenis sampah ♻️',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 20),

                        // Image Preview Area
                        _buildImagePreview()
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .scale(begin: const Offset(0.9, 0.9)),

                        const SizedBox(height: 24),

                        // Action Buttons
                        if (_image == null) ...[
                          _buildCameraButton()
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 12),
                          _buildGalleryButton()
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .slideX(begin: 0.2, end: 0),
                        ] else ...[
                          _buildProcessButton()
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: EcoButton(
                                  text: 'Kamera',
                                  onPressed: () =>
                                      _pickImage(ImageSource.camera),
                                  icon: Icons.camera_alt,
                                  isOutlined: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: EcoButton(
                                  text: 'Galeri',
                                  onPressed: () =>
                                      _pickImage(ImageSource.gallery),
                                  icon: Icons.photo,
                                  isOutlined: true,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                        ],

                        const SizedBox(height: 24),

                        // Tips Section
                        if (_image == null) _buildTipsSection(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return EcoCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _image == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum ada gambar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih gambar untuk memulai deteksi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_image!, fit: BoxFit.cover),
                    if (_showResult && _detectionResult != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _detectionResult!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kepercayaan: $_confidence',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return EcoCard(
      onTap: () => _pickImage(ImageSource.camera),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambil Foto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan kamera untuk mengambil foto',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryButton() {
    return EcoCard(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.photo,
              color: AppColors.accentBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih dari Galeri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih gambar dari galeri perangkat',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      height: 56,
      child: EcoButton(
        text: 'Deteksi Sekarang',
        onPressed: _processImage,
        icon: Icons.search,
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips Foto yang Baik 💡',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 12),
        _buildTipItem(
          'Pastikan pencahayaan cukup',
          Icons.wb_sunny_outlined,
        ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),
        _buildTipItem(
          'Fokus pada objek sampah',
          Icons.center_focus_strong,
        ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),
        _buildTipItem(
          'Hindari bayangan berlebih',
          Icons.highlight_off,
        ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2, end: 0),
        _buildTipItem(
          'Ambil dari jarak yang jelas',
          Icons.zoom_in,
        ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showResultBottomSheet(String type, String confidence, bool isOrganic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Success Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Deteksi Berhasil! ✨',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // Result Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EcoCard(
                color: isOrganic
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.accentBlue.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      type,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOrganic
                            ? AppColors.success
                            : AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.analytics,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kepercayaan: $confidence',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EcoCard(
                      child: Text(
                        isOrganic
                            ? 'Sampah organik adalah sampah yang berasal dari makhluk hidup dan dapat terurai secara alami. Contoh: sisa makanan, daun, dan kulit buah. Sampah ini bisa dijadikan kompos.'
                            : 'Sampah anorganik adalah sampah yang tidak dapat terurai secara alami. Contoh: plastik, kaca, logam. Sampah ini perlu didaur ulang untuk mengurangi pencemaran lingkungan.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: EcoButton(
                      text: 'Scan Lagi',
                      onPressed: () {
                        Navigator.pop(context);
                        _clearImage();
                      },
                      icon: Icons.refresh,
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EcoButton(
                      text: 'Selesai',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
