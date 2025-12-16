import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Step 1: Tampilkan logo saja selama 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Step 2: Tampilkan text "PILAR"
    if (mounted) {
      setState(() {
        _showText = true;
      });
    }
    
    // Step 3: Tunggu 1.5 detik lagi, lalu navigasi ke onboarding
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo SVG
            SvgPicture.asset(
              'assets/images/Logo Icon Pilar.svg',
              width: 80,
              height: 80,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms, duration: 400.ms),
            
            // Text "PILAR" - hanya muncul setelah _showText = true
            if (_showText)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: const Text(
                  'PILAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),
              ),
          ],
        ),
      ),
    );
  }
}