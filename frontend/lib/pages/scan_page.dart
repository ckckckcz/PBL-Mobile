import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pilar/constants/app_colors.dart';
import '../models/scan_history_model.dart';
import '../services/scan_history_service.dart';
import '../services/api_service.dart';
import '../constants/app_strings.dart';
import '../utils/permission_helper.dart';
import 'scan_result.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isFlashOn = false;
  final ImagePicker _imagePicker = ImagePicker();
  final ScanHistoryService _historyService = ScanHistoryService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Camera not supported on web
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
      return;
    }

    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Izin kamera diperlukan untuk menggunakan fitur scan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamera tidak tersedia. Silakan gunakan galeri.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera belum siap')),
      );
      return;
    }

    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();

      if (mounted) {
        // Create dummy scan result
        await _navigateToResult(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Request gallery permission using helper
      final permissionGranted =
          await PermissionHelper.requestGalleryPermission();

      if (!permissionGranted) {
        // Check if permanently denied
        final isPermanentlyDenied =
            await PermissionHelper.isGalleryPermissionPermanentlyDenied();

        if (isPermanentlyDenied && mounted) {
          // Show dialog to open settings
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(AppStrings.permissionRequired),
              content: const Text(AppStrings.permissionPhotoMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(AppStrings.openSettings),
                ),
              ],
            ),
          );

          if (shouldOpenSettings == true) {
            await openAppSettings();
          }
        } else if (mounted) {
          // Permission denied but not permanently
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.permissionGalleryRequired),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        if (mounted) {
          // Navigate to result page
          await _navigateToResult(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorPickImage}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _toggleFlash() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _navigateToResult(String imagePath) async {
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          },
        );
      }

      // Call the actual prediction API
      final apiService = ApiService();
      final result = await apiService.predictWaste(imagePath);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Check if prediction was successful
      if (!result['success']) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menganalisis gambar'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Extract data from API response
      final data = result['data'];
      final wasteType = data['wasteType'] as String;
      final category = data['category'] as String;
      final confidence = (data['confidence'] as num).toDouble();
      final description = data['description'] as String;

      // Convert tips from API format to local format
      final apiTips = data['tips'] as List<dynamic>;
      final tips = apiTips.map((tip) {
        return {
          'title': tip['title'] as String,
          'color': tip['color'] as String,
        };
      }).toList();

      // Generate scan ID and date
      final scanId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      final dateFormatter =
          '${now.day} ${_getMonthName(now.month)} ${now.year}';

      // Create scan history object
      final scanHistory = ScanHistory(
        id: scanId,
        imageUri: imagePath,
        wasteType: wasteType,
        category: category,
        confidence: confidence,
        description: '$description\nDipindai: $dateFormatter',
        tips: tips.map((e) => Map<String, String>.from(e)).toList(),
        scanDate: now,
      );

      // Save to history
      await _historyService.saveScan(scanHistory);

      // Navigate to result page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultPage(
              imageUri: imagePath,
              wasteType: scanHistory.wasteType,
              category: scanHistory.category,
              confidence: scanHistory.confidence,
              description: scanHistory.description,
              tips: scanHistory.tips,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backendnya belum dinyalain coy'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('[SCAN] Error in _navigateToResult: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: kIsWeb
          ? _buildWebView()
          : _isCameraInitialized
              ? _buildCameraView()
              : _buildLoadingView(),
    );
  }

  Widget _buildWebView() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.camera(PhosphorIconsStyle.regular),
                        size: 64,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kamera tidak tersedia di Web',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan pilih gambar dari galeri',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon:
                          Icon(PhosphorIcons.image(PhosphorIconsStyle.regular)),
                      label: const Text('Pilih dari Galeri'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat kamera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_cameraController == null) {
      return const Center(child: Text('Kamera tidak tersedia'));
    }

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Camera Preview
        SizedBox(
          width: size.width,
          height: size.height,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),

        // Overlay
        SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Scan Area
              Expanded(
                child: _buildScanArea(),
              ),

              // Controls
              _buildControls(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Title
          Text(
            kIsWeb ? 'Upload Gambar' : 'Pindai Sampah',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Placeholder
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildScanArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scan Frame
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                // Top Left Corner
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white, width: 4),
                        left: BorderSide(color: Colors.white, width: 4),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Top Right Corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white, width: 4),
                        right: BorderSide(color: Colors.white, width: 4),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Bottom Left Corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 4),
                        left: BorderSide(color: Colors.white, width: 4),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Bottom Right Corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 4),
                        right: BorderSide(color: Colors.white, width: 4),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Instruction Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Arahkan kamera ke sampah untuk memindai',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (!_isCameraInitialized) ...[
            const SizedBox(height: 8),
            const Text(
              'Menginisialisasi kamera...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFFFA500),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery Button
          GestureDetector(
            onTap: _isScanning ? null : _pickImageFromGallery,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.image(PhosphorIconsStyle.regular),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Scan Button
          GestureDetector(
            onTap: (_isScanning || !_isCameraInitialized) ? null : _takePicture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isScanning
                        ? const CircularProgressIndicator(
                            color: AppColors.primary,
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Flash Button
          GestureDetector(
            onTap: _isScanning ? null : _toggleFlash,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isFlashOn
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFlashOn
                    ? PhosphorIcons.lightning(PhosphorIconsStyle.fill)
                    : PhosphorIcons.lightning(PhosphorIconsStyle.regular),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
