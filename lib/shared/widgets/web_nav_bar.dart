import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/auth_provider.dart';

class WebNavBar extends ConsumerWidget implements PreferredSizeWidget {
  const WebNavBar({super.key, required this.activeTab});

  final String activeTab;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      _TabItem('Dashboard', '/home', 'home'),
      _TabItem('History', '/history', 'history'),
      _TabItem('Encyclopedia', '/encyclopedia', 'encyclopedia'),
      _TabItem('Statistics', '/statistics', 'statistics'),
      _TabItem('Settings', '/settings', 'settings'),
    ];

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryDark.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo & Branding
          GestureDetector(
            onTap: () => context.go('/home'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NumiIT',
                    style: AppTypography.display(
                      20,
                      color: AppColors.accent,
                      weight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),

          // Navigation Tabs
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tabs.map((tab) => _buildTab(context, tab)).toList(),
            ),
          ),

          // User Profile / Auth State
          if (auth.isAuthenticated)
            _buildProfileAvatar(context, ref, auth)
          else
            _buildSignInButton(context),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, _TabItem tab) {
    final isActive = activeTab.toLowerCase() == tab.key.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.go(tab.path),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tab.label,
                style: AppTypography.body(
                  14,
                  weight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.accent
                      : (isDark ? Colors.white70 : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 24 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, WidgetRef ref, AuthState auth) {
    final name = auth.displayName ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'settings') {
          context.go('/settings');
        } else         if (val == 'logout') {
          ref.read(authProvider.notifier).logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')),
          );
          context.go('/home');
        }
      },
      offset: const Offset(0, 56),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            Text(
              name,
              style: AppTypography.body(14, weight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              child: Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings, size: 18),
              const SizedBox(width: 8),
              Text('Settings', style: AppTypography.body(13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Log Out', style: AppTypography.body(13, color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => context.push('/login', extra: GoRouterState.of(context).uri.toString()),
      child: Text(
        'Sign In',
        style: AppTypography.body(13, weight: FontWeight.bold),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final String path;
  final String key;

  _TabItem(this.label, this.path, this.key);
}
