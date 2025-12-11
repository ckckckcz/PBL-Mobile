import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/auth/auth_page.dart';
import 'pages/auth/forgot_password.dart';
import 'pages/auth/change_password_step1.dart';
import 'pages/auth/change_password_step2.dart';
import 'pages/main_navigation.dart';
import 'pages/scan_page.dart';
import 'pages/scan_result.dart';
import 'pages/about_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Waste Detector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(initialTab: 0),
        '/login': (context) => const AuthPage(initialTab: 0),
        '/register': (context) => const AuthPage(initialTab: 1),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/change-password-step1': (context) => const ChangePasswordStep1Page(),
        '/change-password-step2': (context) => const ChangePasswordStep2Page(),
        '/home': (context) => const MainNavigation(initialIndex: 0),
        '/scan': (context) => const ScanPage(),
        '/scan_with_nav': (context) => const MainNavigation(initialIndex: 1),
        '/history': (context) => const MainNavigation(initialIndex: 2),
        '/profile': (context) => const MainNavigation(initialIndex: 3),
        '/about_app': (context) => const AboutAppPage(),
        '/scan_result': (context) => const ScanResultPage(),
      },
    );
  }
}
