import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2E3A2F),
                          size: 24,
                        ),
                      ),
                    ),

                    // Title
                    const Text(
                      'Tentang Aplikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3A2F),
                      ),
                    ),

                    // Placeholder
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 32),

                // Logo and Info Section
                Column(
                  children: [
                    // Logo Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/profile/Logo Icon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      'PILAR Apps',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E3A2F),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Version
                    const Text(
                      'Versi 1.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF607D6B),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Developer
                    const Text(
                      'Developed by Kelompok 04',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF607D6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
