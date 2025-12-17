import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/scan_history_model.dart';
import 'scan_page.dart'; // Added import

class HistoryDetailPage extends StatelessWidget {
  final ScanHistory scanHistory;

  const HistoryDetailPage({
    Key? key,
    required this.scanHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
            color: Colors.black,
            size: 24,
          ),
        ),
        title: Text(
          'Detail',
          style: AppTypography.bodyLargeSemibold.copyWith(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            _buildWasteInfo(),
            _buildTipsSection(),
            _buildScanAgainButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: double.infinity,
        height: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.neutral[50], // Inner placeholder color
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (scanHistory.imageUri.startsWith('http')) {
      return Image.network(
        scanHistory.imageUri,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (scanHistory.imageUri.startsWith('assets/')) {
      return Image.asset(
        scanHistory.imageUri,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return Image.file(
        File(scanHistory.imageUri),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          PhosphorIcons.image(PhosphorIconsStyle.regular),
          size: 64,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildWasteInfo() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jenis Sampah',
            style: AppTypography.bodySmallMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                scanHistory.wasteType,
                style: AppTypography.bodyLargeSemibold.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18, // Slightly adjusted for 'Large' feeling
                ),
              ),
              _buildCategoryBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dipindai: ${scanHistory.formattedDate}',
            style: AppTypography.bodySmallRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final isOrganic = scanHistory.category.toLowerCase().contains('organik') &&
        !scanHistory.category.toLowerCase().contains('anorganik');
    // Colors based on screenshots
    final color = isOrganic
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800); // Correct orange for inorganic text
    final bgColor = isOrganic
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF8E1); // Correct light yellow for inorganic bg

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        scanHistory.category,
        style: AppTypography.bodySmallSemibold.copyWith(
          color: color,
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips Mengolah',
            style: AppTypography.bodyLargeSemibold.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...scanHistory.tips.asMap().entries.map((entry) {
            return _buildTipItem(entry.value, entry.key);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTipItem(Map<String, String> tip, int index) {
    // Cycle through 1 to 5
    final iconIndex = (index % 5) + 1;
    final iconPath = 'assets/images/tips/id_$iconIndex.svg';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral[50], // Very light grey/white
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              iconPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Text(
              tip['title'] ?? tip['text'] ?? '', // Handle both keys if possible
              style: AppTypography.bodyMediumRegular.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAgainButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.arrowUUpLeft(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pindai Ulang',
              style: AppTypography.bodyMediumSemibold.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
