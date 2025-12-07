import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'about_app.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy data - replace with actual user data from your service
  final String userName = 'Riana Salsabila';
  final String userEmail = 'riana@jalar.id';
  final String userPhone = '+62 821-2345-6789';
  final String userBirthDate = '23/05/2000';
  final int scanCount = 458;
  final int organicCount = 458;
  final int anorganicCount = 458;

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
                const SizedBox(height: 8),
                // Profile Header Section
                _buildProfileHeader(),
                const SizedBox(height: 24),
                // Stats Section
                _buildStatsSection(),
                const SizedBox(height: 24),
                // Menu Items
                _buildMenuItem(
                  icon: PhosphorIcons.clockCounterClockwise(
                      PhosphorIconsStyle.regular),
                  title: 'Riwayat',
                  onTap: () {
                    Navigator.pushNamed(context, '/history');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                  title: 'Akun Saya',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          userName: userName,
                          userEmail: userEmail,
                          userPhone: userPhone,
                          userBirthDate: userBirthDate,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: PhosphorIcons.lockKey(PhosphorIconsStyle.regular),
                  title: 'Ubah Kata Sandi',
                  onTap: () {
                    // TODO: Navigate to change password page
                    debugPrint('Navigate to Ubah Kata Sandi');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: PhosphorIcons.info(PhosphorIconsStyle.regular),
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
                _buildMenuItem(
                  icon: PhosphorIcons.signOut(PhosphorIconsStyle.regular),
                  title: 'Keluar',
                  isDestructive: true,
                  onTap: () {
                    _showLogoutDialog();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://via.placeholder.com/60',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF4CAF50),
                    child: Icon(
                      PhosphorIcons.user(PhosphorIconsStyle.regular),
                      size: 30,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Name
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Decorative image placeholder
          Align(
            alignment: Alignment.topRight,
            child: Image.network(
              'https://via.placeholder.com/80x60',
              width: 80,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.leaf(PhosphorIconsStyle.regular),
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                count: scanCount.toString(),
                label: 'Pemindaian',
                color: const Color(0xFF2196F3),
              ),
              _buildStatItem(
                icon: PhosphorIcons.leaf(PhosphorIconsStyle.regular),
                count: organicCount.toString(),
                label: 'Organik',
                color: const Color(0xFF4CAF50),
              ),
              _buildStatItem(
                icon: PhosphorIcons.flask(PhosphorIconsStyle.regular),
                count: anorganicCount.toString(),
                label: 'Anorganik',
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required PhosphorIconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E3A2F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF607D6B),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required PhosphorIconData icon,
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Keluar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Color(0xFF607D6B)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Handle logout logic
                debugPrint('User logged out');
              },
              child: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}