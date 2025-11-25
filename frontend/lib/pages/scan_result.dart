import 'package:flutter/material.dart';
import 'dart:io';

class ScanResultPage extends StatefulWidget {
  final String? imageUri;
  final String? wasteType;
  final String? category;
  final double? confidence;
  final String? description;
  final List<dynamic>? tips;

  const ScanResultPage({
    Key? key,
    this.imageUri,
    this.wasteType,
    this.category,
    this.confidence,
    this.description,
    this.tips,
  }) : super(key: key);

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  bool _devModeVisible = false;

  // Sample data for tips images
  final List<String> _tipImages = [
    'assets/images/tips/id_1.png',
    'assets/images/tips/id_2.png',
    'assets/images/tips/id_3.png',
    'assets/images/tips/id_4.png',
    'assets/images/tips/id_5.png',
  ];

  String _getTipImage(int index) {
    return _tipImages[index % _tipImages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    // Image
                    _buildImage(),

                    const SizedBox(height: 24),

                    // Result Card
                    _buildResultCard(),

                    const SizedBox(height: 24),

                    // Tips Section
                    if (widget.tips != null && widget.tips!.isNotEmpty)
                      _buildTipsSection(),

                    const SizedBox(height: 24),

                    // Rescan Button
                    _buildRescanButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF2E3A2F),
                size: 24,
              ),
            ),
          ),

          // Title
          const Text(
            'Hasil Pemindaian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A2F),
            ),
          ),

          // Dev Mode Button
          GestureDetector(
            onTap: () {
              setState(() {
                _devModeVisible = true;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.code,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.imageUri != null
          ? _buildImageWidget()
          : Container(
              color: const Color(0xFFF5F5F5),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image,
                size: 64,
                color: Color(0xFF9E9E9E),
              ),
            ),
    );
  }

  Widget _buildImageWidget() {
    try {
      // Clean the path - remove any file:// prefix if present
      String cleanPath = widget.imageUri!;
      if (cleanPath.startsWith('file://')) {
        cleanPath = cleanPath.substring(7);
      }

      final file = File(cleanPath);

      // Check if it's a local file
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: $error');
            return _buildImageError();
          },
        );
      } else if (widget.imageUri!.startsWith('http')) {
        // Try network image
        return Image.network(
          widget.imageUri!,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading network image: $error');
            return _buildImageError();
          },
        );
      } else {
        return _buildImageError();
      }
    } catch (e) {
      debugPrint('Exception loading image: $e');
      return _buildImageError();
    }
  }

  Widget _buildImageError() {
    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported,
            size: 64,
            color: Color(0xFF9E9E9E),
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat gambar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      size: 16,
                      color: _getCategoryColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.category ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Confidence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.confidence?.toStringAsFixed(1) ?? '0'}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Waste Type
          Text(
            widget.wasteType ?? 'Jenis Sampah Tidak Diketahui',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3A2F),
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            widget.description ?? 'Tidak ada deskripsi tersedia',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.category?.toLowerCase()) {
      case 'organik':
        return const Color(0xFF4CAF50);
      case 'anorganik':
        return const Color(0xFF2196F3);
      case 'b3':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category?.toLowerCase()) {
      case 'organik':
        return Icons.eco;
      case 'anorganik':
        return Icons.recycling;
      case 'b3':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tips Pengelolaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3A2F),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: List.generate(
                widget.tips!.length,
                (index) {
                  final tip = widget.tips![index];
                  final tipTitle = tip is Map ? tip['title'] ?? '' : tip.toString();
                  final tipColor = tip is Map ? tip['color'] ?? '#4CAF50' : '#4CAF50';

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < widget.tips!.length - 1 ? 16 : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(tipColor).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            _getTipImage(index),
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.lightbulb_outline,
                                color: _parseColor(tipColor),
                                size: 20,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Tip Text
                        Expanded(
                          child: Text(
                            tipTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2E3A2F),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescanButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Pop until we reach the main navigation
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Pindai Ulang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '');

      // Add FF for alpha if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF4CAF50); // Default color
    }
  }
}
