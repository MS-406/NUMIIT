import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import 'app_bottom_nav.dart';
import 'web_nav_bar.dart';
import 'app_drawer.dart';
import 'app_header.dart';

class AppLayoutShell extends ConsumerWidget {
  const AppLayoutShell({super.key, required this.child, required this.uri});

  final Widget child;
  final String uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    // If it's the camera screen on mobile, we render it full screen without headers/footers
    if (uri.startsWith('/camera') && !isWide) {
      return child;
    }

    // Determine active tab name for WebNavBar
    String activeTab = 'home';
    if (uri.startsWith('/history')) {
      activeTab = 'history';
    } else if (uri.startsWith('/encyclopedia')) {
      activeTab = 'encyclopedia';
    } else if (uri.startsWith('/statistics')) {
      activeTab = 'statistics';
    } else if (uri.startsWith('/settings')) {
      activeTab = 'settings';
    }

    // Determine current index for AppBottomNav
    int bottomNavIndex = 0;
    if (uri.startsWith('/home')) {
      bottomNavIndex = 0;
    } else if (uri.startsWith('/camera')) {
      bottomNavIndex = 1;
    } else if (uri.startsWith('/history')) {
      bottomNavIndex = 2;
    } else if (uri.startsWith('/settings')) {
      bottomNavIndex = 3;
    } else if (uri.startsWith('/encyclopedia')) {
      bottomNavIndex = 0;
    } else if (uri.startsWith('/statistics')) {
      bottomNavIndex = 0;
    }

    // Check if bottom nav should be visible on mobile
    final showBottomNav = !isWide && (
      uri.startsWith('/home') ||
      uri.startsWith('/history') ||
      uri.startsWith('/settings') ||
      uri.startsWith('/encyclopedia') ||
      uri.startsWith('/statistics')
    );

    // Determine if we should show a common AppBar on mobile
    // We don't show the common AppBar on /home and /history because they have custom Slivers with search/greeting
    final showCommonAppBar = !isWide && (
      uri.startsWith('/settings') ||
      uri.startsWith('/encyclopedia') ||
      uri.startsWith('/statistics') ||
      uri.startsWith('/profile')
    );

    // Get Title for the common AppBar
    String appBarTitle = 'NumiIT';
    if (uri.startsWith('/settings')) {
      appBarTitle = 'Settings';
    } else if (uri.startsWith('/encyclopedia')) {
      appBarTitle = 'Coin Encyclopedia';
    } else if (uri.startsWith('/statistics')) {
      appBarTitle = 'Statistics';
    } else if (uri.startsWith('/result')) {
      appBarTitle = 'Scan Result';
    } else if (uri.startsWith('/profile')) {
      appBarTitle = 'Researcher Profile';
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppNavigationDrawer(),
      appBar: isWide
          ? PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: WebNavBar(activeTab: activeTab),
            )
          : (showCommonAppBar
              ? AppHeader(title: appBarTitle, showAvatar: !uri.startsWith('/profile'))
              : null),
      bottomNavigationBar: showBottomNav ? AppBottomNav(currentIndex: bottomNavIndex) : null,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isWide ? 1100 : double.infinity,
          ),
          child: child,
        ),
      ),
    );
  }
}
