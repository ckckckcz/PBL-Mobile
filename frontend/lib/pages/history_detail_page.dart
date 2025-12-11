// FILE: history_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/scan_history_model.dart';

class HistoryDetailPage extends StatelessWidget {
  final ScanHistory scanHistory;

  const HistoryDetailPage({
    Key? key,
    required this.scanHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text(
          'Detail',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(height: 16),
              _buildWasteInfo(),
              const SizedBox(height: 24),
              _buildTipsSection(),
              const SizedBox(height: 24),
              _buildScanAgainButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImageWidget(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Sampah',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                scanHistory.wasteType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            _buildCategoryBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dipindai: ${_formatDate(scanHistory.scanDate)}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    final isOrganic = scanHistory.category.toLowerCase() == 'organik';
    final color = isOrganic ? const Color(0xFFFF9800) : const Color(0xFF2196F3);
    final bgColor = isOrganic
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE3F2FD);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        scanHistory.category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips Mengolah',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...scanHistory.tips.asMap().entries.map((entry) {
          return _buildTipItem(entry.value, entry.key);
        }).toList(),
      ],
    );
  }

  Widget _buildTipItem(Map<String, String> tip, int index) {
    // Icons sesuai dengan desain gambar
    final iconData = [
      PhosphorIcons.trash(PhosphorIconsStyle.regular),
      PhosphorIcons.package(PhosphorIconsStyle.regular),
      PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.regular),
      PhosphorIcons.lightbulb(PhosphorIconsStyle.regular),
      PhosphorIcons.storefront(PhosphorIconsStyle.regular),
    ];

    final iconColors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];

    final iconBgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFE0F7FA),
      const Color(0xFFFFF3E0),
      const Color(0xFFF3E5F5),
    ];

    final icon = iconData[index % iconData.length];
    final iconColor = iconColors[index % iconColors.length];
    final iconBgColor = iconBgColors[index % iconBgColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Text(
              tip['title'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26C6DA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.regular),
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Pindai Ulang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}