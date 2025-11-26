import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/main_navigation.dart';
import 'pages/about_app.dart';
import 'pages/scan_result.dart';
import 'pages/scan_page.dart';

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
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
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
