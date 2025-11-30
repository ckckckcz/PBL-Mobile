import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class ChangePasswordStep2Page extends StatefulWidget {
  const ChangePasswordStep2Page({super.key});

  @override
  State<ChangePasswordStep2Page> createState() => _ChangePasswordStep2PageState();
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
          child: const Icon(
            Icons.lock,
            color: Color(0xFF4CAF50),
            size: 35,
          ),
        ),
      ],
    );
  }

  /// Build title
  Widget _buildTitle() {
    return const Text(
      'Ubah Kata Sandi',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
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
        const Text(
          'Buat Kata Sandi Baru',
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
              hintText: 'Masukkan kata sandi',
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
                onPressed: _toggleNewPasswordVisibility,
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF757575),
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
              hintText: 'Masukkan kata sandi',
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
                onPressed: _toggleConfirmPasswordVisibility,
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF757575),
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
        color: const Color(0xFF4CAF50),
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
                : const Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
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
