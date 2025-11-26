import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'about_app.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E3A2F),
                  ),
                ),

                const SizedBox(height: 32),

                // Profile Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Icon(
                          PhosphorIcons.user(PhosphorIconsStyle.regular),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Profile Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'User Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E3A2F),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'user@email.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF607D6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Menu Items
                const Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A2F),
                  ),
                ),

                const SizedBox(height: 16),

                // About App Button
                _buildMenuItemWithImage(
                  context,
                  imagePath: 'assets/images/Logo.png',
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutAppPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Edit Profile Button
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular),
                  title: 'Edit Profil',
                  onTap: () {
                    // TODO: Navigate to edit profile
                  },
                ),

                const SizedBox(height: 12),

                // Settings Button
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.gear(PhosphorIconsStyle.regular),
                  title: 'Pengaturan',
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),

                const SizedBox(height: 12),

                // Privacy Policy Button
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.regular),
                  title: 'Kebijakan Privasi',
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),

                const SizedBox(height: 32),

                // Logout Button
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.signOut(PhosphorIconsStyle.regular),
                  title: 'Keluar',
                  isDestructive: true,
                  onTap: () {
                    // TODO: Implement logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement logout logic
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Keluar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : const Color(0xFF2E3A2F),
                  ),
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                color: isDestructive ? Colors.red : const Color(0xFF607D6B),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithImage(
    BuildContext context, {
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    PhosphorIcons.info(PhosphorIconsStyle.regular),
                    color: Color(0xFF4CAF50),
                    size: 24,
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E3A2F),
                  ),
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                color: Color(0xFF607D6B),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

