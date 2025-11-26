import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// About App Page - Refactored with Clean Architecture
/// Displays information about the application
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildAppInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with back button and title
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBackButton(context),
        _buildHeaderTitle(),
        const SizedBox(width: 40), // Placeholder for symmetry
      ],
    );
  }

  /// Build back button
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
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
        child: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }

  /// Build header title
  Widget _buildHeaderTitle() {
    return const Text(
      AppStrings.aboutApp,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Build app information section
  Widget _buildAppInfo() {
    return Column(
      children: [
        _buildAppLogo(),
        const SizedBox(height: 24),
        _buildAppName(),
        const SizedBox(height: 4),
        _buildAppVersion(),
        const SizedBox(height: 4),
        _buildDeveloperInfo(),
        const SizedBox(height: 32),
        _buildAppDescription(),
      ],
    );
  }

  /// Build app logo
  Widget _buildAppLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/Logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildLogoFallback();
          },
        ),
      ),
    );
  }

  /// Build logo fallback when image fails to load
  Widget _buildLogoFallback() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          'PILAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  /// Build app name
  Widget _buildAppName() {
    return const Text(
      AppStrings.appName,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Build app version
  Widget _buildAppVersion() {
    return Text(
      AppStrings.appVersion,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Build developer info
  Widget _buildDeveloperInfo() {
    return Text(
      AppStrings.developer,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Build app description
  Widget _buildAppDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.appTagline,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PILAR (Pilah Sampah) adalah aplikasi yang membantu Anda mengidentifikasi dan memilah jenis sampah dengan mudah menggunakan teknologi AI. '
            'Dengan PILAR, Anda dapat memindai sampah menggunakan kamera dan mendapatkan informasi kategori sampah serta tips pengelolaannya.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeaturesList(),
        ],
      ),
    );
  }

  /// Build features list
  Widget _buildFeaturesList() {
    final features = [
      '📸 Pemindaian sampah dengan kamera',
      '🤖 Identifikasi otomatis menggunakan AI',
      '📊 Riwayat pemindaian tersimpan',
      '💡 Tips pengelolaan sampah',
      '♻️ Edukasi ramah lingkungan',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitur Utama:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            )),
      ],
    );
  }
}
