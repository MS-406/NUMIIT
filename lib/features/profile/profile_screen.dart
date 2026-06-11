import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/history_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final history = ref.watch(historyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = auth.isAuthenticated ? (auth.displayName ?? 'Researcher') : 'Guest Researcher';
    final email = auth.isAuthenticated ? (auth.email ?? '') : 'guest@numiit.org';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  color: isDark ? AppColors.primaryMid.withOpacity(0.4) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: auth.isAuthenticated
                              ? AppColors.accent
                              : AppColors.accent.withOpacity(0.2),
                          foregroundColor: auth.isAuthenticated
                              ? AppColors.primaryDark
                              : AppColors.accent,
                          child: auth.isAuthenticated
                              ? Text(
                                  initial,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 36),
                                )
                              : const Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: AppTypography.display(24,
                              color: isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: AppTypography.body(14,
                              color: AppColors.textSecondary, weight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: auth.isAuthenticated
                                ? AppColors.successGreen.withOpacity(0.12)
                                : Colors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            auth.isAuthenticated ? 'Authenticated Account' : 'Guest Mode',
                            style: AppTypography.body(11,
                                color: auth.isAuthenticated ? AppColors.successGreen : AppColors.accent,
                                weight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  color: isDark ? AppColors.primaryMid.withOpacity(0.4) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: AppTypography.display(16,
                              color: isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        const Divider(height: 24, color: Colors.white10),
                        _statRow('Total Scans Recorded', '${history.totalScans}'),
                        _statRow('Most Common Script', history.scans.isEmpty
                            ? 'None'
                            : history.scans.map((s) => s.primaryScript).fold<Map<String, int>>({}, (m, s) {
                                m[s] = (m[s] ?? 0) + 1;
                                return m;
                              }).entries.reduce((a, b) => a.value >= b.value ? a : b).key),
                        _statRow('Joined Date', auth.isAuthenticated ? 'June 2026' : 'N/A (Guest)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Button Action
                if (auth.isAuthenticated)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully')),
                      );
                      context.go('/home');
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      'Log Out',
                      style: AppTypography.body(16, weight: FontWeight.bold),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.push('/login', extra: {'redirect': '/profile', 'tab': 1});
                    },
                    icon: const Icon(Icons.login),
                    label: Text(
                      'Sign In / Register',
                      style: AppTypography.body(16, weight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body(13, color: AppColors.textSecondary, weight: FontWeight.w500)),
          Text(value, style: AppTypography.body(14, weight: FontWeight.bold)),
        ],
      ),
    );
  }
}
