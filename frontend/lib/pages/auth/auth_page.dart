import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/api_service.dart';

class AuthPage extends StatefulWidget {
  final int initialTab; // 0 for login, 1 for register

  const AuthPage({super.key, this.initialTab = 0});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Register Controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  // Services
  final _apiService = ApiService();

  // State
  bool _isLoginLoading = false;
  bool _isRegisterLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  // ==================== LOGIN METHODS ====================

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoginLoading = true);

    try {
      final result = await _apiService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar(
          result['message'] ?? AppStrings.loginSuccess,
          isError: false,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        _showDialog(
          title: 'Login Gagal',
          message: result['message'] ?? AppStrings.errorLogin,
        );
      }
    } catch (error) {
      if (mounted) {
        _showDialog(
          title: 'Backend Belum Nyala',
          message:
              'Backendnya belum dinyalain, gausa login langsung pencet button atas kiri aja 👆',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoginLoading = false);
      }
    }
  }

  // ==================== REGISTER METHODS ====================

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar('Anda harus menyetujui syarat dan ketentuan',
          isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isRegisterLoading = true);

    try {
      final result = await _apiService.register(
        fullName: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar(
          result['message'] ?? 'Registrasi berhasil!',
          isError: false,
        );
        // Switch to login tab
        _tabController.animateTo(0);
        // Clear register form
        _registerNameController.clear();
        _registerEmailController.clear();
        _registerPasswordController.clear();
        _registerConfirmPasswordController.clear();
        setState(() => _agreeToTerms = false);
      } else {
        _showDialog(
          title: 'Registrasi Gagal',
          message: result['message'] ?? 'Terjadi kesalahan saat registrasi',
        );
      }
    } catch (error) {
      if (mounted) {
        _showDialog(
          title: 'Error',
          message: 'Terjadi kesalahan: ${error.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegisterLoading = false);
      }
    }
  }

  // ==================== UI HELPER METHODS ====================

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

  // ==================== BUILD METHODS ====================

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
                child: _buildTabSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildTitle() {
    return const Text(
      'Selamat Datang di PILAR',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Masuk atau daftar untuk menggunakan semua fitur PILAR.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.9),
        height: 1.4,
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoginForm(),
                _buildRegisterForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(4),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(26),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        labelColor: const Color(0xFF1F1F1F),
        unselectedLabelColor: const Color(0xFF8E8E93),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Masuk'),
          Tab(text: 'Daftar'),
        ],
      ),
    );
  }

  // ==================== LOGIN FORM ====================

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildLoginEmailField(),
            const SizedBox(height: 20),
            _buildLoginPasswordField(),
            const SizedBox(height: 8),
            _buildForgotPasswordLink(),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginEmailField() {
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
        TextFormField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Masukkan Email',
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email harus diisi';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
          enabled: !_isLoginLoading,
        ),
      ],
    );
  }

  Widget _buildLoginPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kata Sandi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          decoration: InputDecoration(
            hintText: 'Masukkan kata sandi',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
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
                  _obscureLoginPassword = !_obscureLoginPassword;
                });
              },
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF757575),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          enabled: !_isLoginLoading,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoginLoading
            ? null
            : () => Navigator.pushNamed(context, '/forgot-password'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Lupa kata sandi?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
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
          onTap: _isLoginLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: _isLoginLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Masuk',
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

  // ==================== REGISTER FORM ====================

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildRegisterNameField(),
            const SizedBox(height: 20),
            _buildRegisterEmailField(),
            const SizedBox(height: 20),
            _buildRegisterPasswordField(),
            const SizedBox(height: 20),
            _buildRegisterConfirmPasswordField(),
            const SizedBox(height: 16),
            _buildTermsCheckbox(),
            const SizedBox(height: 24),
            _buildRegisterButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Lengkap',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _registerNameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama lengkap',
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama lengkap harus diisi';
            }
            if (value.trim().length < 3) {
              return 'Nama minimal 3 karakter';
            }
            return null;
          },
          enabled: !_isRegisterLoading,
        ),
      ],
    );
  }

  Widget _buildRegisterEmailField() {
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
        TextFormField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Masukkan Email',
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email harus diisi';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
          enabled: !_isRegisterLoading,
        ),
      ],
    );
  }

  Widget _buildRegisterPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kata Sandi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _registerPasswordController,
          obscureText: _obscureRegisterPassword,
          decoration: InputDecoration(
            hintText: 'Buat kata sandi',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
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
                  _obscureRegisterPassword = !_obscureRegisterPassword;
                });
              },
              icon: Icon(
                _obscureRegisterPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF757575),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          enabled: !_isRegisterLoading,
        ),
      ],
    );
  }

  Widget _buildRegisterConfirmPasswordField() {
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
        TextFormField(
          controller: _registerConfirmPasswordController,
          obscureText: _obscureRegisterConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Konfirmasi kata sandi',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
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
                  _obscureRegisterConfirmPassword =
                      !_obscureRegisterConfirmPassword;
                });
              },
              icon: Icon(
                _obscureRegisterConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF757575),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi kata sandi harus diisi';
            }
            if (value != _registerPasswordController.text) {
              return 'Kata sandi tidak cocok';
            }
            return null;
          },
          enabled: !_isRegisterLoading,
          onFieldSubmitted: (_) => _handleRegister(),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: _isRegisterLoading
                ? null
                : (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _isRegisterLoading
                ? null
                : () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF424242),
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'Saya setuju dengan '),
                  TextSpan(
                    text: 'Syarat dan Ketentuan',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' yang berlaku'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
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
          onTap: _isRegisterLoading ? null : _handleRegister,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: _isRegisterLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Daftar',
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
