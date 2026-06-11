import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/auth_provider.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryMid : AppColors.accent.withOpacity(0.12),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: auth.isAuthenticated ? AppColors.accent : Colors.grey.shade400,
              foregroundColor: auth.isAuthenticated ? AppColors.primaryDark : Colors.white,
              child: Text(
                auth.isAuthenticated && auth.displayName?.isNotEmpty == true
                    ? auth.displayName![0].toUpperCase()
                    : 'G',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            accountName: Text(
              auth.isAuthenticated ? (auth.displayName ?? 'Researcher') : 'Guest Mode',
              style: AppTypography.display(16, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            accountEmail: Text(
              auth.isAuthenticated ? (auth.email ?? '') : 'guest@numiit.org',
              style: AppTypography.body(12, color: AppColors.textSecondary),
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(
                  icon: Icons.home_outlined,
                  label: 'Home Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                ),
                _drawerTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Scan Coin',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/camera');
                  },
                ),
                _drawerTile(
                  icon: Icons.history,
                  label: 'Scan History',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/history');
                  },
                ),
                _drawerTile(
                  icon: Icons.menu_book,
                  label: 'Encyclopedia',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/encyclopedia');
                  },
                ),
                _drawerTile(
                  icon: Icons.bar_chart_outlined,
                  label: 'Statistics',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/statistics');
                  },
                ),
                _drawerTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/settings');
                  },
                ),
                _drawerTile(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
                const Divider(color: Colors.white10),
                _drawerTile(
                  icon: Icons.info_outline,
                  label: 'About NumiIT',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _drawerTile(
                  icon: Icons.help_outline,
                  label: 'Help & Guide',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Auth Button at the bottom
          Padding(
            padding: const EdgeInsets.all(20),
            child: auth.isAuthenticated
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully')),
                      );
                      context.go('/home');
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Log Out'),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/login', extra: '/home');
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Sign In / Register'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent, size: 22),
      title: Text(
        label,
        style: AppTypography.body(14, weight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryMid
            : Colors.white,
        title: Text('About NumiIT', style: AppTypography.display(18)),
        content: Text(
          'NumiIT v1.0.0 is an academic research application designed for automated Indic coin inscription detection, transliteration, and translation. Built for historians, researchers, and numismatic hobbyists.',
          style: AppTypography.body(13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryMid
            : Colors.white,
        title: Text('Help Guide', style: AppTypography.display(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpRow('1.', 'Fill the Camera overlay grid frame with the coin.'),
            _helpRow('2.', 'Provide sufficient even lighting and capture.'),
            _helpRow('3.', 'Wait for the AI pipeline step milestones.'),
            _helpRow('4.', 'Explore translations and read historical context.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got It', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _helpRow(String step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$step ', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: AppTypography.body(13))),
        ],
      ),
    );
  }
}
