import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../widgets/scan_result_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return ScanResultHeader(
      onBackPressed: _handleBackPressed,
      onDevModePressed: _handleDevModePressed,
    );
  }

  /// Build scrollable content
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildResultSection(),
          const SizedBox(height: 24),
          _buildTipsSection(),
          const SizedBox(height: 24),
          _buildRescanSection(),
        ],
      ),
    );
  }

  /// Build image section
  Widget _buildImageSection() {
    return ScannedImageCard(imageUri: widget.imageUri);
  }

  /// Build result section
  Widget _buildResultSection() {
    return ResultCard(
      wasteType: widget.wasteType,
      category: widget.category,
      confidence: widget.confidence,
      description: widget.description,
    );
  }

  /// Build tips section
  Widget _buildTipsSection() {
    return TipsSection(tips: widget.tips);
  }

  /// Build rescan button section
  Widget _buildRescanSection() {
    return RescanButton(onPressed: _handleRescan);
  }

  /// Handle back button press
  void _handleBackPressed() {
    Navigator.pop(context);
  }

  /// Handle dev mode button press
  void _handleDevModePressed() {
    setState(() {
      _devModeVisible = true;
    });

    // Show dev mode dialog
    _showDevModeDialog();
  }

  /// Handle rescan button press
  void _handleRescan() {
    // Pop until we reach the main navigation
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Show developer mode dialog
  void _showDevModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.code(PhosphorIconsStyle.regular),
                color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Developer Mode'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDevModeInfo('Image URI', widget.imageUri ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDevModeInfo('Waste Type', widget.wasteType ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDevModeInfo('Category', widget.category ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDevModeInfo(
                'Confidence',
                '${widget.confidence?.toStringAsFixed(2) ?? 'N/A'}%',
              ),
              const SizedBox(height: 12),
              _buildDevModeInfo(
                'Tips Count',
                '${widget.tips?.length ?? 0} items',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Build developer mode info row
  Widget _buildDevModeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
