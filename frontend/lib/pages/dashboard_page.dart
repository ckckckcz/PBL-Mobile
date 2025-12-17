import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/tips_list_widget.dart';
import '../models/article_model.dart';
import '../services/scan_history_service.dart';
import '../services/profile_service.dart';
import '../models/user_model.dart';
import 'dart:io';

class DashboardPage extends StatefulWidget {
  final int dataVersion;

  const DashboardPage({
    super.key,
    this.dataVersion = 0,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Article> articles = Article.getSampleArticles();
  final ScanHistoryService _scanHistoryService = ScanHistoryService();
  final ProfileService _profileService = ProfileService();

  @override
  void didUpdateWidget(DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataVersion != oldWidget.dataVersion) {
      _loadStats();
    }
  }

  UserModel? _user;
  int _totalScans = 0;
  int _organicWaste = 0;
  int _inorganicWaste = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _scanHistoryService.getStatistics();
    final user = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _totalScans = stats['total'] ?? 0;
        _organicWaste = stats['organik'] ?? 0;
        _inorganicWaste = stats['anorganik'] ?? 0;
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Container(
          color: AppColors.neutral[50],
          child: Column(
            children: [
              // Fixed Header
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),

              // Scrollable Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadStats(); // Reload actual stats
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil diperbarui'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Total Pemindaian Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildTotalScansCard()
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                        ),

                        const SizedBox(height: 8),

                        // Stats Row (Organik & Anorganik)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildStatsRow()
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                        ),

                        const SizedBox(height: 12),

                        // Tips Mengelola Sampah
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips Mengelola Sampah',
                                style: AppTypography.bodyLargeSemibold.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const TipsListWidget(),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.name ?? 'Riana Salsabila',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: ClipOval(
              child: _buildProfileImage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_user?.imagePath != null && File(_user!.imagePath!).existsSync()) {
      return Image.file(
        File(_user!.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/profile.png'),
      );
    }
    return Image.asset(
      'assets/images/profile.png',
      fit: BoxFit.cover,
    );
  }

  Widget _buildTotalScansCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11695E), Color(0xFF0E564D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pemindaian',
                      style: AppTypography.bodyMediumRegular.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_totalScans',
                  style: AppTypography.display2Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Pemindaian',
                  style: AppTypography.bodyMediumRegular.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Icon(
              PhosphorIcons.arrowUpRight(PhosphorIconsStyle.regular),
              size: 32,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Sampah Organik',
            value: '$_organicWaste',
            subtitle: 'Pemindaian',
            color: const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'Sampah Anorganik',
            value: '$_inorganicWaste',
            subtitle: 'Pemindaian',
            color: const Color(0xFF42A5F5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.heading1Semibold.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: AppColors.neutral[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }
}
