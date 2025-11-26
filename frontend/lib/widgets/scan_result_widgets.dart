import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../utils/image_helper.dart';

/// Reusable widgets for Scan Result Page
/// Extracted to improve code organization and reusability

/// Result card widget displaying scan information
class ResultCard extends StatelessWidget {
  final String? wasteType;
  final String? category;
  final double? confidence;
  final String? description;

  const ResultCard({
    Key? key,
    this.wasteType,
    this.category,
    this.confidence,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadges(),
          const SizedBox(height: 16),
          _buildWasteType(),
          const SizedBox(height: 12),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        _CategoryBadge(category: category),
        const Spacer(),
        _ConfidenceBadge(confidence: confidence),
      ],
    );
  }

  Widget _buildWasteType() {
    return Text(
      wasteType ?? 'Jenis Sampah Tidak Diketahui',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      description ?? 'Tidak ada deskripsi tersedia',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.5,
      ),
    );
  }
}

/// Category badge widget
class _CategoryBadge extends StatelessWidget {
  final String? category;

  const _CategoryBadge({this.category});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(category ?? '');
    final categoryIcon = AppColors.getCategoryIcon(category ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: 16,
            color: categoryColor,
          ),
          const SizedBox(width: 6),
          Text(
            category ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confidence badge widget
class _ConfidenceBadge extends StatelessWidget {
  final double? confidence;

  const _ConfidenceBadge({this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${confidence?.toStringAsFixed(1) ?? '0'}%',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}

/// Scanned image display widget
class ScannedImageCard extends StatelessWidget {
  final String? imageUri;

  const ScannedImageCard({
    Key? key,
    this.imageUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUri != null && imageUri!.isNotEmpty
          ? _buildImage()
          : _buildPlaceholder(),
    );
  }

  Widget _buildImage() {
    return ImageHelper.buildImage(
      path: imageUri!,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      errorWidget: _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image,
        size: 64,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported,
            size: 64,
            color: AppColors.textTertiary,
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
}

/// Tips section widget
class TipsSection extends StatelessWidget {
  final List<dynamic>? tips;

  const TipsSection({
    Key? key,
    this.tips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tips == null || tips!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 16),
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Tips Pengelolaan',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _buildTipsList(),
      ),
    );
  }

  List<Widget> _buildTipsList() {
    return List.generate(
      tips!.length,
      (index) {
        final tip = tips![index];
        final tipTitle = tip is Map ? tip['title'] ?? '' : tip.toString();
        final tipColor = tip is Map ? tip['color'] ?? '#4CAF50' : '#4CAF50';

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < tips!.length - 1 ? 16 : 0,
          ),
          child: TipItem(
            title: tipTitle,
            color: tipColor,
            index: index,
          ),
        );
      },
    );
  }
}

/// Individual tip item widget
class TipItem extends StatelessWidget {
  final String title;
  final String color;
  final int index;

  const TipItem({
    Key? key,
    required this.title,
    required this.color,
    required this.index,
  }) : super(key: key);

  // Sample data for tips images
  static final List<String> _tipImages = [
    'assets/images/tips/id_1.png',
    'assets/images/tips/id_2.png',
    'assets/images/tips/id_3.png',
    'assets/images/tips/id_4.png',
    'assets/images/tips/id_5.png',
  ];

  String _getTipImage(int index) {
    return _tipImages[index % _tipImages.length];
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedColor = _parseColor(color);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIcon(parsedColor),
        const SizedBox(width: 16),
        _buildText(),
      ],
    );
  }

  Widget _buildIcon(Color parsedColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: parsedColor.withOpacity(0.2),
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
            color: parsedColor,
            size: 20,
          );
        },
      ),
    );
  }

  Widget _buildText() {
    return Expanded(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Header widget for scan result page
class ScanResultHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback? onDevModePressed;

  const ScanResultHeader({
    Key? key,
    required this.onBackPressed,
    this.onDevModePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          _buildTitle(),
          _buildDevButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBackPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Hasil Pemindaian',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDevButton() {
    if (onDevModePressed == null) {
      return const SizedBox(width: 40);
    }

    return GestureDetector(
      onTap: onDevModePressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.code,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}

/// Rescan button widget
class RescanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RescanButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
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
}
