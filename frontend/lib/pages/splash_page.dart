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
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 6000));

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
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Text "ILAR"
            // Initial: Centered, Transparent
            // Animation: Wait 1.5s -> Fade In + Slide Right
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: const Text(
                'ILAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  // Stay invisible initially
                  .fadeIn(
                      delay: 1500.ms, duration: 500.ms, curve: Curves.easeIn)
                  .moveX(
                    begin: 0,
                    end: 45,
                    delay: 1500.ms,
                    duration: 1000.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),

            // Logo SVG "P"
            // Animation: Pop Up (Scale) -> Wait -> Slide Left
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
                // Pop Up Effect
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0, 0), // Start from nothing
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut, // "Pop" effect
                )
                // Slide Left Effect
                .moveX(
                  begin: 0,
                  end: -45,
                  delay: 1500.ms,
                  duration: 1000.ms,
                  curve: Curves.easeOutCubic,
                ),
          ],
        ),
      ),
    );
  }
}
