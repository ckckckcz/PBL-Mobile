import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import 'history.dart';
import 'edit_profile_page.dart';
import 'auth/change_password_step1.dart';
import 'about_app.dart';
import '../services/api_service.dart';
import '../services/scan_history_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScanHistoryService _scanHistoryService = ScanHistoryService();
  int _totalScans = 0;
  int _organicScans = 0;
  int _inorganicScans = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _scanHistoryService.getStatistics();
    setState(() {
      _totalScans = stats['total'] ?? 0;
      _organicScans = stats['organik'] ?? 0;
      _inorganicScans = stats['anorganik'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral[50],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              color: AppColors.puertoRico[50], // Primary 50
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: SvgPicture.asset(
                      'assets/images/profile illustrator.svg',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 20),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.neutral[500],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Riana Salsabila',
                            style: AppTypography.bodyMediumSemibold.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Pemindaian',
                                style: AppTypography.bodyMediumMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.scan(
                                        PhosphorIconsStyle.regular),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_totalScans',
                                    style: AppTypography.heading3Semibold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Organik',
                                style: AppTypography.bodyMediumMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.orangeSlice(
                                        PhosphorIconsStyle.regular),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_organicScans',
                                    style: AppTypography.heading3Semibold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Anorganik',
                                style: AppTypography.bodyMediumMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.beerBottle(
                                        PhosphorIconsStyle.regular),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_inorganicScans',
                                    style: AppTypography.heading3Semibold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.neutral[100],
                      height: 1,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryPage()),
                        ).then((_) =>
                            _loadStats()); // Refresh stats when returning from History
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIcons.clockCounterClockwise(
                                  PhosphorIconsStyle.regular),
                              color: AppColors.neutral[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Riwayat',
                              style: AppTypography.bodyMediumMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              PhosphorIcons.caretRight(
                                  PhosphorIconsStyle.regular),
                              color: AppColors.neutral[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16, top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(
                            userName: 'Riana Salsabila',
                            userEmail: 'riana.salsabila@example.com',
                            userPhone: '+62 81234567890',
                            userBirthDate: '23/05/2000',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.user(PhosphorIconsStyle.regular),
                            color: AppColors.neutral[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Akun Saya',
                            style: AppTypography.bodyMediumMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            PhosphorIcons.caretRight(
                                PhosphorIconsStyle.regular),
                            color: AppColors.neutral[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ChangePasswordStep1Page()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.lock(PhosphorIconsStyle.regular),
                            color: AppColors.neutral[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ubah Kata Sandi',
                            style: AppTypography.bodyMediumMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            PhosphorIcons.caretRight(
                                PhosphorIconsStyle.regular),
                            color: AppColors.neutral[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutAppPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.info(PhosphorIconsStyle.regular),
                            color: AppColors.neutral[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tentang Aplikasi',
                            style: AppTypography.bodyMediumMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            PhosphorIcons.caretRight(
                                PhosphorIconsStyle.regular),
                            color: AppColors.neutral[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleLogout,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.signOut(PhosphorIconsStyle.regular),
                            color: AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Keluar',
                            style: AppTypography.bodyMediumMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;

      // Call logout API (clears token locally too)
      await ApiService().logout();

      if (!mounted) return;

      // Navigate to login page and remove all routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }
}
