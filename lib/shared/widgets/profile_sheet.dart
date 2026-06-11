import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/auth_provider.dart';

void showUserProfileSheet(BuildContext context, WidgetRef ref) {
  final auth = ref.read(authProvider);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? AppColors.primaryMid : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: auth.isAuthenticated
                        ? AppColors.accent
                        : AppColors.accent.withValues(alpha: 0.2),
                    foregroundColor: auth.isAuthenticated
                        ? AppColors.primaryDark
                        : AppColors.accent,
                    child: auth.isAuthenticated
                        ? Text(
                            auth.displayName?.isNotEmpty == true
                                ? auth.displayName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          )
                        : const Icon(Icons.person, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isAuthenticated
                              ? (auth.displayName ?? 'Researcher')
                              : 'Guest Researcher',
                          style: AppTypography.display(18,
                              color: isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.isAuthenticated
                              ? (auth.email ?? '')
                              : 'Log in to sync your scans',
                          style: AppTypography.body(13,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),

              // Actions
              if (auth.isAuthenticated) ...[
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.accent),
                  title: Text('Settings',
                      style: AppTypography.body(14,
                          color: isDark ? Colors.white : AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Log Out',
                      style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authProvider.notifier).logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                  },
                ),
              ] else ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/login', extra: GoRouterState.of(context).uri.toString());
                  },
                  icon: const Icon(Icons.login),
                  label: Text('Sign In / Register',
                      style: AppTypography.body(14, weight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.accent),
                  title: Text('Settings',
                      style: AppTypography.body(14,
                          color: isDark ? Colors.white : AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
