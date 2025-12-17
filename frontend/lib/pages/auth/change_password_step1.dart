import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_typography.dart';

class ChangePasswordStep1Page extends StatefulWidget {
  const ChangePasswordStep1Page({super.key});

  @override
  State<ChangePasswordStep1Page> createState() =>
      _ChangePasswordStep1PageState();
}

class _ChangePasswordStep1PageState extends State<ChangePasswordStep1Page> {
  final _currentPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _obscureCurrentPassword = !_obscureCurrentPassword;
    });
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Navigate to step 2 with current password
    Navigator.pushNamed(
      context,
      '/change-password-step2',
      arguments: _currentPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
              color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ubah Kata Sandi',
          style: AppTypography.heading3Semibold.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLockIcon(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 40),
                  _buildCurrentPasswordField(),
                  const SizedBox(height: 32),
                  _buildContinueButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build lock icon
  Widget _buildLockIcon() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.lockKey(PhosphorIconsStyle.regular),
              color: AppColors.primary,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  /// Build title (Removed as it's now in AppBar, but keeping method if needed or just empty/spacing)
  Widget _buildTitle() {
    return const SizedBox.shrink(); // Title moved to AppBar
  }

  /// Build description
  Widget _buildDescription() {
    return const Text(
      'Perbarui kata sandi Anda untuk menjaga keamanan akun.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF757575),
        height: 1.4,
      ),
    );
  }

  /// Build current password field
  Widget _buildCurrentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kata Sandi Saat Ini',
          style: AppTypography.bodyMediumMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            decoration: InputDecoration(
              hintText: 'Masukkan kata sandi',
              hintStyle: AppTypography.bodyMediumRegular.copyWith(
                color: AppColors.textTertiary,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              suffixIcon: IconButton(
                onPressed: _toggleCurrentPasswordVisibility,
                icon: Icon(
                  _obscureCurrentPassword
                      ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular)
                      : PhosphorIcons.eye(PhosphorIconsStyle.regular),
                  color: AppColors.textSecondary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi harus diisi';
              }
              if (value.length < 6) {
                return 'Kata sandi minimal 6 karakter';
              }
              return null;
            },
            enabled: !_isLoading,
          ),
        ),
      ],
    );
  }

  /// Build continue button
  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleContinue,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Lanjutkan',
                    style: AppTypography.bodyLargeSemibold.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
