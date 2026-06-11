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
      height: 56,
      selectedIndex: currentIndex,
      onDestinationSelected: go,
      backgroundColor: AppColors.surfaceCard,
      indicatorColor: AppColors.accent.withValues(alpha: 0.3),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        _dest(Icons.home_outlined, Icons.home, 'Home', 0),
        _scanDest(1),
        _dest(Icons.history, Icons.history, 'History', 2),
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

  NavigationDestination _scanDest(int index) {
    final active = index == currentIndex;
    return NavigationDestination(
      icon: _scanIcon(active),
      selectedIcon: _scanIcon(true),
      label: 'Scan',
    );
  }

  Widget _scanIcon(bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, -1),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.camera_alt,
        color: AppColors.primaryDark,
        size: 16,
      ),
    );
  }

  Widget _withDot(IconData icon, bool active) {
    return Icon(icon, size: 24);
  }
}
