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
    try {
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
    } catch (e) {
      return _buildPlaceholder();
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
    final displayCategory = _getDisplayCategory(scanHistory.category);
    final categoryColor = AppColors.getCategoryColor(scanHistory.category);

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
          _buildInfoRow(
            'Jenis Sampah',
            displayCategory,
            valueColor: categoryColor,
            icon: AppColors.getCategoryIcon(scanHistory.category),
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          _buildInfoRow(
            'Akurasi',
            '${scanHistory.confidence.toStringAsFixed(1)}%',
            valueColor: AppColors.success,
            icon: PhosphorIcons.target(PhosphorIconsStyle.regular),
          ),
          const SizedBox(height: 16),
          Text(
            'Dipindai: ${scanHistory.formattedDate}',
            style: AppTypography.bodySmallRegular.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayCategory(String? cat) {
    final lower = cat?.toLowerCase() ?? '';
    if (['organik', 'organic', 'sampah organik'].contains(lower))
      return 'Organik';
    if (['anorganik', 'inorganic', 'sampah anorganik'].contains(lower))
      return 'Anorganik';
    return cat ?? (cat?.isNotEmpty == true ? cat! : '-');
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24, color: AppColors.textSecondary),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
