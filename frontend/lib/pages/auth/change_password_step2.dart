import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../services/api_service.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_typography.dart';

class ChangePasswordStep2Page extends StatefulWidget {
  const ChangePasswordStep2Page({super.key});

  @override
  State<ChangePasswordStep2Page> createState() =>
      _ChangePasswordStep2PageState();
}

class _ChangePasswordStep2PageState extends State<ChangePasswordStep2Page> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _currentPassword = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current password from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      _currentPassword = args as String;
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.changePassword(
        currentPassword: _currentPassword,
        newPassword: _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _handleChangeSuccess(result['message']);
      } else {
        _handleChangeFailure(result['message']);
      }
    } catch (error) {
      if (mounted) {
        _handleChangeError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleChangeSuccess(String? message) {
    _showDialog(
      title: 'Berhasil',
      message: message ?? 'Kata sandi berhasil diubah.',
      onConfirm: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );
  }

  void _handleChangeFailure(String? message) {
    _showDialog(
      title: 'Gagal',
      message: message ?? 'Gagal mengubah kata sandi. Silakan coba lagi.',
    );
  }

  void _handleChangeError(String error) {
    _showDialog(
      title: 'Error',
      message: 'Terjadi kesalahan. Silakan coba lagi nanti.',
    );
  }

  void _showDialog({
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onConfirm ?? () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
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
                  _buildNewPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 32),
                  _buildChangeButton(),
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

  /// Build title
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

  /// Build new password field
  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Kata Sandi Baru',
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
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
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
                onPressed: _toggleNewPasswordVisibility,
                icon: Icon(
                  _obscureNewPassword
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

  /// Build confirm password field
  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfirmasi Kata Sandi',
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
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
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
                onPressed: _toggleConfirmPasswordVisibility,
                icon: Icon(
                  _obscureConfirmPassword
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
                return 'Konfirmasi kata sandi harus diisi';
              }
              if (value != _newPasswordController.text) {
                return 'Kata sandi tidak cocok';
              }
              return null;
            },
            enabled: !_isLoading,
          ),
        ),
      ],
    );
  }

  /// Build change button
  Widget _buildChangeButton() {
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
          onTap: _isLoading ? null : _handleChangePassword,
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
                    'Ubah Kata Sandi',
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
