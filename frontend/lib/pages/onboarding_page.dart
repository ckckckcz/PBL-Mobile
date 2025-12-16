import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data konten Onboarding dengan SVG
  final List<Map<String, String>> _onboardingData = [
    {
      'svg': 'assets/images/Onboarding 1.svg',
      'title': 'Scan Sekali, Langsung Tau',
      'description':
          'Arahkan kamera, biar aplikasi yang bantu pilihkan tempat sampahnya.',
    },
    {
      'svg': 'assets/images/Onboarding 2.svg',
      'title': 'Kenali Jenis Sampah',
      'description':
          'Lihat info singkat tentang plastik, kardus, organik, dan lainnya.',
    },
    {
      'svg': 'assets/images/Onboarding 3.svg',
      'title': 'Mulai Kebiasaan Baik',
      'description': 'Pilah sampah dengan mudah untuk bantu bumi tetap bersih.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    // Navigate ke halaman auth/login
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _buildOnboardingItem(
                  index: index,
                  svg: _onboardingData[index]['svg']!,
                  title: _onboardingData[index]['title']!,
                  description: _onboardingData[index]['description']!,
                ),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingItem({
    required int index,
    required String svg,
    required String title,
    required String description,
  }) {
    // Fixed height as requested
    const double containerHeight = 520.0;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Ilustrasi inside Container
          SafeArea(
            child: Container(
              width: double.infinity,
              height: containerHeight,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.neutral[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Transform.scale(
                scale: index == 2 ? 1.8 : 1.0,
                child: SvgPicture.asset(
                  svg,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ).animate().scale(
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                      // If index is 2, we want the animation to end at scale 1.0 (relative to the Transform),
                      // effectively resulting in 2.0 total scale.
                      // Default scale animation goes to 1.0, so this stacks correctly.
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Teks Judul & Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: AppTypography.heading2Medium.copyWith(
                    color: Colors.black,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.left,
                  style: AppTypography.bodySmallRegular.copyWith(
                    color: AppColors.neutral[600],
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: PrimaryButton(
        text: _currentPage == _onboardingData.length - 1 ? 'Masuk' : 'Lanjut',
        onPressed: _nextPage,
      ),
    );
  }
}
