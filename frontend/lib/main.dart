import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/main_navigation.dart';
import 'pages/about_app.dart';
import 'pages/scan_result.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainNavigation(initialIndex: 0),
        '/dashboard': (context) => const MainNavigation(initialIndex: 0), // Alias for /home
        '/scan': (context) => const MainNavigation(initialIndex: 1),
        '/history': (context) => const MainNavigation(initialIndex: 2),
        '/profile': (context) => const MainNavigation(initialIndex: 3),
        '/about_app': (context) => const AboutAppPage(),
        '/scan_result': (context) => const ScanResultPage(),
      },
    );
  }
}
