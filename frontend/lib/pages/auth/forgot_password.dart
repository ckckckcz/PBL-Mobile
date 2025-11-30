import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Services
  final _apiService = ApiService();

  // State
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handle forgot password action
  Future<void> _handleResetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _handleResetSuccess(result['message']);
      } else {
        _handleResetFailure(result['message']);
      }
    } catch (error) {
      if (mounted) {
        _handleResetError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle successful password reset
  void _handleResetSuccess(String? message) {
    _showDialog(
      title: 'Email Terkirim',
      message: message ?? 'Instruksi reset password telah dikirim ke email Anda.',
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  /// Handle password reset failure
  void _handleResetFailure(String? message) {
    _showDialog(
      title: 'Gagal',
      message: message ?? 'Gagal mengirim email reset password. Silakan coba lagi.',
    );
  }

  /// Handle password reset error
  void _handleResetError(String error) {
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
      'Lupa kata sandi?',
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
      'Masukkan email Anda untuk menerima instruksi reset kata sandi.',
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
              _buildEmailField(),
              const SizedBox(height: 32),
              _buildResetButton(),
              const SizedBox(height: 24),
              _buildBackToLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build email field
  Widget _buildEmailField() {
    return CustomTextField.email(
      controller: _emailController,
      label: 'Email',
      hint: 'contoh@email.com',
      validator: Validators.email,
      enabled: !_isLoading,
    );
  }

  /// Build reset button
  Widget _buildResetButton() {
    return CustomButton.primary(
      text: 'Kirim',
      onPressed: _isLoading ? null : _handleResetPassword,
      isLoading: _isLoading,
      height: 56,
    );
  }

  /// Build back to login link
  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ingat kata sandi?',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Masuk',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
