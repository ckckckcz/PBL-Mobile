import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common_widgets.dart';
import '../widgets/eco_tips_carousel.dart';
import '../widgets/tips_list_widget.dart';
import '../models/article_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Article> articles = Article.getSampleArticles();

  // Data statistik
  final int totalScans = 458;
  final int organicWaste = 258;
  final int inorganicWaste = 200;

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
                    await Future.delayed(const Duration(seconds: 1));
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
                  'Selamat Pagi,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Riana Salsabila',
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
              image: const DecorationImage(
                image: AssetImage('assets/images/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
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
                  '$totalScans',
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
            value: '$organicWaste',
            subtitle: 'Pemindaian',
            color: const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'Sampah Anorganik',
            value: '$inorganicWaste',
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
}
