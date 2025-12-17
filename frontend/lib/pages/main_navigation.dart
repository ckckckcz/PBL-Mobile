import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dashboard_page.dart';
import 'scan_page.dart';
import 'history.dart';
import 'profile_page.dart';
import '../constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  int _dataVersion = 0; // Trigger for rebuilding pages to refresh data

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Method to force refresh
  void _refreshData() {
    setState(() {
      _dataVersion++;
    });
  }

  // Generate pages dynamically to pass the unique key or callback
  List<Widget> get _pages {
    return [
      DashboardPage(
        key: ValueKey('dashboard_$_dataVersion'),
      ),
      const ScanPage(), // This will not be used as a page, scan opens fullscreen
      HistoryPage(
        key: ValueKey('history_$_dataVersion'),
        onDataChanged: _refreshData,
      ),
      ProfilePage(
        key: ValueKey('profile_$_dataVersion'),
      ),
    ];
  }

  void _onItemTapped(int index) {
    // If scan button is tapped, navigate to fullscreen scan page
    if (index == 1) {
      Navigator.pushNamed(context, '/scan').then((_) {
        // When returning from scan, refresh data (History and Profile)
        _refreshData();
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages, // Access via getter
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                  label: 'Beranda',
                  index: 0,
                ),
                _buildNavItem(
                  icon: PhosphorIcons.scan(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.scan(PhosphorIconsStyle.fill),
                  label: 'Pindai',
                  index: 1,
                ),
                _buildNavItem(
                  icon: PhosphorIcons.clockCounterClockwise(
                      PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.clockCounterClockwise(
                      PhosphorIconsStyle.fill),
                  label: 'Riwayat',
                  index: 2,
                ),
                _buildNavItem(
                  icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = const Color(0xFF9E9E9E);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
