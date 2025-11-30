import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Services
  final _apiService = ApiService();

  // State
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login action
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _handleLoginSuccess(result['message']);
      } else {
        _handleLoginFailure(result['message']);
      }
    } catch (error) {
      if (mounted) {
        _handleLoginError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle successful login
  void _handleLoginSuccess(String? message) {
    _showSnackBar(
      message ?? AppStrings.loginSuccess,
      isError: false,
    );

    // Navigate to home
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  /// Handle login failure
  void _handleLoginFailure(String? message) {
    _showDialog(
      title: 'Login Gagal',
      message: message ?? AppStrings.errorLogin,
    );
  }

  /// Handle login error
  void _handleLoginError(String error) {
    _showDialog(
      title: 'Backend Belum Nyala',
      message:
          'Backendnya belum dinyalain, gausa login langsung pencet button atas kiri aja 👆',
    );
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show alert dialog
  void _showDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.ok,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to register page
  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
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
      onTap: () => Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      ),
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
      'Masuk untuk melanjutkan aktivitasmu',
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
      'Akses akunmu dan mulai gunakan fitur PILAR dengan mudah.',
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
              const SizedBox(height: 8),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              const SizedBox(height: 24),
              _buildRegisterLink(),
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
      label: AppStrings.email,
      hint: 'contoh@email.com',
      validator: Validators.email,
      enabled: !_isLoading,
    );
  }

  /// Build password field
  Widget _buildPasswordField() {
    return CustomTextField.password(
      controller: _passwordController,
      label: AppStrings.password,
      hint: 'Masukkan password',
      validator: Validators.password,
      enabled: !_isLoading,
      onSubmitted: (_) => _handleLogin(),
    );
  }

  /// Build login button
  Widget _buildLoginButton() {
    return CustomButton.primary(
      text: AppStrings.login,
      onPressed: _isLoading ? null : _handleLogin,
      isLoading: _isLoading,
      height: 56,
    );
  }

  /// Build register link
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _isLoading ? null : _navigateToRegister,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Daftar di sini',
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
