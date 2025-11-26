import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/eco_tips_carousel.dart';
import '../models/article_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Article> articles = Article.getSampleArticles();

  // Data statistik dummy
  final int wasteDetected = 127;
  final int organicWaste = 78;
  final int inorganicWaste = 49;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.regular)),
            onPressed: () {
              _showNotificationBottomSheet(context);
            },
          ),
          IconButton(
            icon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.regular)),
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Stats Section
                  _buildStatsSection()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions()
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Eco Tips Carousel
                  Text(
                    'Tips Ramah Lingkungan 🌿',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 12),

                  const EcoTipsCarousel().animate().fadeIn(
                        delay: 500.ms,
                        duration: 400.ms,
                      ),

                  const SizedBox(height: 24),

                  // Articles Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edukasi Lingkungan 📚',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showAllArticlesBottomSheet(context);
                        },
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 12),

                  // Articles List (showing first 3)
                  ...articles.take(3).map((article) {
                    return ArticleCard(
                      title: article.title,
                      description: article.description,
                      emoji: article.iconEmoji,
                      onTap: () {
                        _showArticleDetailBottomSheet(context, article);
                      },
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/scan'),
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.camera(PhosphorIconsStyle.regular)),
        label: const Text('Scan'),
      )
          .animate()
          .fadeIn(delay: 800.ms, duration: 400.ms)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
    );
  }

  Widget _buildWelcomeCard() {
    return EcoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang! 👋',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu telah membantu mengurangi sampah sebanyak $wasteDetected item!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                EcoButton(
                  text: 'Lihat Profile',
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.leaf(PhosphorIconsStyle.regular),
                size: 30, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Kamu 📊',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Scan',
                value: '$wasteDetected',
                icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Organik',
                value: '$organicWaste',
                icon: PhosphorIcons.plant(PhosphorIconsStyle.regular),
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          title: 'Anorganik',
          value: '$inorganicWaste',
          icon: PhosphorIcons.recycle(PhosphorIconsStyle.regular),
          iconColor: AppColors.accentBlue,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat ⚡',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
                label: 'Scan',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/scan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular),
                label: 'Riwayat',
                color: AppColors.accentBlue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur riwayat segera hadir'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return EcoCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showArticleDetailBottomSheet(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        article.iconEmoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      article.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    EcoCard(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.lightbulb(PhosphorIconsStyle.regular),
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Setiap tindakan kecil yang kamu lakukan memiliki dampak besar untuk bumi kita! 🌍',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllArticlesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Semua Artikel Edukasi',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ArticleCard(
                    title: article.title,
                    description: article.description,
                    emoji: article.iconEmoji,
                    onTap: () {
                      Navigator.pop(context);
                      _showArticleDetailBottomSheet(context, article);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              PhosphorIcons.bell(PhosphorIconsStyle.regular),
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Notifikasi',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada notifikasi baru',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  Icon(PhosphorIcons.user(PhosphorIconsStyle.regular), color: AppColors.primary),
              title: const Text('Profile'),
              trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular), size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading:
                  Icon(PhosphorIcons.globe(PhosphorIconsStyle.regular), color: AppColors.primary),
              title: const Text('Bahasa'),
              trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular), size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur pengaturan bahasa segera hadir'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(PhosphorIcons.signOut(PhosphorIconsStyle.regular), color: AppColors.error),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


