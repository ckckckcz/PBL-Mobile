import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Services
  final _apiService = ApiService();

  // State
  bool _isLoading = false;
  bool _emailVerified = false; // Track if email is verified
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle verify email action
  Future<void> _handleVerifyEmail() async {
    // Validate email only
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Email harus diisi', isError: true);
      return;
    }

    final emailError = Validators.email(_emailController.text.trim());
    if (emailError != null) {
      _showSnackBar(emailError, isError: true);
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
        // Email found, show password fields
        setState(() {
          _emailVerified = true;
        });
        _showSnackBar(
          'Email ditemukan! Silakan masukkan kata sandi baru.',
          isError: false,
        );
      } else {
        _showSnackBar(
          result['message'] ?? 'Email tidak terdaftar',
          isError: true,
        );
      }
    } catch (error) {
      if (mounted) {
        _showSnackBar(AppStrings.errorNetwork, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle reset password action
  Future<void> _handleResetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check password match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok', isError: true);
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.resetPassword(
        email: _emailController.text.trim(),
        newPassword: _newPasswordController.text,
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
      title: 'Berhasil',
      message: message ??
          'Kata sandi berhasil diubah. Silakan login dengan kata sandi baru.',
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      onConfirm: () {
        Navigator.pop(context); // Close dialog
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  /// Handle password reset failure
  void _handleResetFailure(String? message) {
    _showDialog(
      title: 'Gagal',
      message: message ?? 'Gagal mengubah kata sandi. Silakan coba lagi.',
      icon: Icons.error,
      iconColor: AppColors.error,
    );
  }

  /// Handle password reset error
  void _handleResetError(String error) {
    _showDialog(
      title: 'Error',
      message: AppStrings.errorNetwork,
      icon: Icons.error,
      iconColor: AppColors.error,
    );
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show alert dialog
  void _showDialog({
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm ?? () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Lupa Kata Sandi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                  _buildEmailField(),

                  // Show password fields only after email is verified
                  if (_emailVerified) ...[
                    const SizedBox(height: 24),
                    _buildNewPasswordField(),
                    const SizedBox(height: 16),
                    _buildConfirmPasswordField(),
                  ],

                  const SizedBox(height: 32),
                  _buildActionButton(),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer light circle
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFEFFBF7),
            shape: BoxShape.circle,
          ),
        ),
        // Inner circle with the lock icon
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFDFF8F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _emailVerified ? Icons.lock_open : Icons.lock,
            color: const Color(0xFF4CAF50),
            size: 35,
          ),
        ),
      ],
    );
  }

  /// Build title
  Widget _buildTitle() {
    return Text(
      _emailVerified ? 'Buat Kata Sandi Baru' : 'Lupa Kata Sandi?',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  /// Build description
  Widget _buildDescription() {
    return Text(
      _emailVerified
          ? 'Masukkan kata sandi baru Anda untuk melanjutkan.'
          : 'Tenang saja! Masukkan email akunmu untuk verifikasi.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF757575),
        height: 1.4,
      ),
    );
  }

  /// Build email field
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Masukkan email',
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: _emailVerified
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                    )
                  : null,
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading && !_emailVerified,
            validator: _emailVerified ? null : Validators.email,
          ),
        ),
      ],
    );
  }

  /// Build new password field
  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kata Sandi Baru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
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
              hintText: 'Masukkan kata sandi baru',
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF757575),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
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
        const Text(
          'Konfirmasi Kata Sandi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
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
              hintText: 'Konfirmasi kata sandi',
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFF757575),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
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

  /// Build action button (Kirim or Ubah Password)
  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading
              ? null
              : (_emailVerified ? _handleResetPassword : _handleVerifyEmail),
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
                    _emailVerified ? 'Ubah Kata Sandi' : 'Kirim',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
