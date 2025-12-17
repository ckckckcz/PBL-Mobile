import 'package:flutter/material.dart';
import 'dart:io';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/scan_history_model.dart';

class HistoryHeader extends StatelessWidget {
  final bool hasHistory;
  final VoidCallback onClearAll;

  const HistoryHeader({
    Key? key,
    required this.hasHistory,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empty space to balance the button on the right
          SizedBox(
            width: hasHistory ? 100 : 0,
          ),
          // Title centered
          const Expanded(
            child: Text(
              'Riwayat', // Changed from AppStrings.history
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, // Matches bodyLargeSemibold/bold
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          // Button on the right
          if (hasHistory)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClearAll,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }
}

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular),
        size: 64,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      AppStrings.historyEmpty,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      AppStrings.historyEmptyDesc,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class HistoryList extends StatelessWidget {
  final List<ScanHistory> historyList;
  final Future<void> Function() onRefresh;
  final void Function(ScanHistory) onItemTap;

  const HistoryList({
    Key? key,
    required this.historyList,
    required this.onRefresh,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 0),
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final scan = historyList[index];
          return HistoryItem(
            scan: scan,
            onTap: () => onItemTap(scan),
          );
        },
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  final ScanHistory scan;
  final VoidCallback onTap;

  const HistoryItem({
    Key? key,
    required this.scan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 16),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(16),
        color: AppColors.neutral[50], // Grey background for icon
        child: _buildThumbnailImage(),
      ),
    );
  }

  Widget _buildThumbnailImage() {
    // Check if it's an asset image
    if (scan.imageUri.startsWith('assets/')) {
      return Image.asset(
        scan.imageUri,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailFallback();
        },
      );
    }

    // Check if it's a file path
    final file = File(scan.imageUri);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailFallback();
        },
      );
    }

    // Fallback icon
    return _buildThumbnailFallback();
  }

  Widget _buildThumbnailFallback() {
    return Icon(
      AppColors.getCategoryIcon(scan.category),
      color: AppColors.getCategoryColor(scan.category),
      size: 32,
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWasteType(),
        const SizedBox(height: 4),
        _buildDateInfo(),
      ],
    );
  }

  Widget _buildWasteType() {
    return Text(
      scan.wasteType,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: Colors.black,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateInfo() {
    return Text(
      scan.formattedDate,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.textSecondary,
      ),
    );
  }
}

class HistoryDialogs {
  /// Show clear all confirmation dialog
  static Future<bool?> showClearAllConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearAllHistory),
        content: const Text(AppStrings.clearAllHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.deleteAll),
          ),
        ],
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
