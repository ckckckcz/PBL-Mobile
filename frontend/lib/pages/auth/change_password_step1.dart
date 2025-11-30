import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePasswordStep1Page extends StatefulWidget {
  const ChangePasswordStep1Page({super.key});

  @override
  State<ChangePasswordStep1Page> createState() => _ChangePasswordStep1PageState();
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

  /// Build current password field
  Widget _buildCurrentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kata Sandi Saat Ini',
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
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
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
                onPressed: _toggleCurrentPasswordVisibility,
                icon: Icon(
                  _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
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

  /// Build continue button
  Widget _buildContinueButton() {
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
                : const Text(
                    'Lanjutkan',
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
