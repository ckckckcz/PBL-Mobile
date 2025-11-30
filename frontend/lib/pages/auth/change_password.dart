import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Services
  final _apiService = ApiService();

  // State
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle change password action
  Future<void> _handleChangePassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.changePassword(
        currentPassword: _currentPasswordController.text.trim(),
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

  /// Handle successful password change
  void _handleChangeSuccess(String? message) {
    _showDialog(
      title: 'Berhasil',
      message: message ?? 'Kata sandi berhasil diubah.',
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  /// Handle password change failure
  void _handleChangeFailure(String? message) {
    _showDialog(
      title: 'Gagal',
      message: message ?? 'Gagal mengubah kata sandi. Silakan coba lagi.',
    );
  }

  /// Handle password change error
  void _handleChangeError(String error) {
    _showDialog(
      title: 'Error',
      message: AppStrings.errorNetwork,
    );
  }

  /// Show alert dialog
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
            child: Text(
              'OK',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle password visibility
  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _obscureCurrentPassword = !_obscureCurrentPassword;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildFormSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
        ],
      ),
    );
  }

  /// Build back button
  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: PhosphorIcon(
          PhosphorIconsRegular.arrowLeft,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  /// Build title
  Widget _buildTitle() {
    return const Text(
      'Ubah kata sandi',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  /// Build subtitle
  Widget _buildSubtitle() {
    return Text(
      'Perbarui kata sandi Anda untuk menjaga keamanan akun.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.9),
        height: 1.4,
      ),
    );
  }

  /// Build form section
  Widget _buildFormSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildCurrentPasswordField(),
              const SizedBox(height: 20),
              _buildNewPasswordField(),
              const SizedBox(height: 20),
              _buildConfirmPasswordField(),
              const SizedBox(height: 32),
              _buildChangeButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Build current password field
  Widget _buildCurrentPasswordField() {
    return CustomTextField(
      controller: _currentPasswordController,
      label: 'Kata Sandi Saat Ini',
      hint: 'Masukkan kata sandi saat ini',
      obscureText: _obscureCurrentPassword,
      validator: Validators.password,
      enabled: !_isLoading,
      prefixIcon: PhosphorIcon(
        PhosphorIconsRegular.lock,
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: PhosphorIcon(
          _obscureCurrentPassword
              ? PhosphorIconsRegular.eyeSlash
              : PhosphorIconsRegular.eye,
          color: AppColors.textTertiary,
          size: 20,
        ),
        onPressed: _toggleCurrentPasswordVisibility,
      ),
    );
  }

  /// Build new password field
  Widget _buildNewPasswordField() {
    return CustomTextField(
      controller: _newPasswordController,
      label: 'Kata Sandi Baru',
      hint: 'Masukkan kata sandi baru',
      obscureText: _obscureNewPassword,
      validator: (value) => Validators.password(value, minLength: 8),
      enabled: !_isLoading,
      prefixIcon: PhosphorIcon(
        PhosphorIconsRegular.lock,
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: PhosphorIcon(
          _obscureNewPassword
              ? PhosphorIconsRegular.eyeSlash
              : PhosphorIconsRegular.eye,
          color: AppColors.textTertiary,
          size: 20,
        ),
        onPressed: _toggleNewPasswordVisibility,
      ),
    );
  }

  /// Build confirm password field
  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      controller: _confirmPasswordController,
      label: 'Konfirmasi Kata Sandi Baru',
      hint: 'Masukkan ulang kata sandi baru',
      obscureText: _obscureConfirmPassword,
      validator: (value) => Validators.confirmPassword(
        value,
        _newPasswordController.text,
      ),
      enabled: !_isLoading,
      prefixIcon: PhosphorIcon(
        PhosphorIconsRegular.lock,
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: PhosphorIcon(
          _obscureConfirmPassword
              ? PhosphorIconsRegular.eyeSlash
              : PhosphorIconsRegular.eye,
          color: AppColors.textTertiary,
          size: 20,
        ),
        onPressed: _toggleConfirmPasswordVisibility,
      ),
    );
  }

  /// Build change button
  Widget _buildChangeButton() {
    return CustomButton.primary(
      text: 'Ubah Kata Sandi',
      onPressed: _isLoading ? null : _handleChangePassword,
      isLoading: _isLoading,
      height: 56,
    );
  }
}
