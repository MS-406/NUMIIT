import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width > 600) {
      return const SizedBox.shrink();
    }

    void go(int index) {
      switch (index) {
        case 0:
          context.go('/home');
        case 1:
          context.push('/camera');
        case 2:
          context.go('/history');
        case 3:
          context.go('/settings');
      }
    }

    return NavigationBar(
      height: 65,
      elevation: 8,
      selectedIndex: currentIndex,
      onDestinationSelected: go,
      backgroundColor: AppColors.surfaceCard,
      indicatorColor: AppColors.accent.withValues(alpha: 0.25),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        _dest(Icons.home_outlined, Icons.home, 'Home', 0),
        _dest(Icons.camera_alt_outlined, Icons.camera_alt, 'Scan', 1),
        _dest(Icons.history_outlined, Icons.history, 'History', 2),
        _dest(Icons.settings_outlined, Icons.settings, 'Settings', 3),
      ],
    );
  }

  NavigationDestination _dest(
    IconData icon,
    IconData selected,
    String label,
    int index,
  ) {
    return NavigationDestination(
      icon: _withDot(icon, index == currentIndex),
      selectedIcon: _withDot(selected, true),
      label: label,
    );
  }

  Widget _withDot(IconData icon, bool active) {
    return Icon(icon, size: 26, color: active ? AppColors.accent : AppColors.textSecondary);
  }
}
