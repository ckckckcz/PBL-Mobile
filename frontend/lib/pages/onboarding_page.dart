import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

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
          'Arahkan kamera, biar aplikasi yang bantu pilihan tempat sampahnya.',
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
    required String svg,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG Ilustrasi
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicture.asset(
                svg,
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack),
            ),
          ),
          const SizedBox(height: 48),

          // Teks Judul & Deskripsi
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF607D6B),
                    height: 1.5,
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
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        children: [
          // Indikator Titik (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Tombol Lanjut / Masuk
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == _onboardingData.length - 1 ? 'Masuk' : 'Lanjut',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}