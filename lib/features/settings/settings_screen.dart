import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/database/db_helper.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/history_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/web_footer.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final history = ref.watch(historyProvider);
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      body: ListView(
        children: [
          _profileCard(context, ref),
          _section('Language'),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(settings.locale.languageCode),
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી')),
              ],
              onChanged: (code) {
                if (code != null) {
                  ref.read(settingsProvider.notifier).setLocale(Locale(code));
                }
              },
            ),
          ),
          _section('Appearance'),
          SwitchListTile(
            title: const Text('Grid overlay (camera)'),
            value: settings.gridOverlay,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setGridOverlay(v),
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(value: AppThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(value: AppThemeMode.system, child: Text('System')),
              ],
              onChanged: (m) {
                if (m != null) ref.read(settingsProvider.notifier).setThemeMode(m);
              },
            ),
          ),
          _section('Detection'),
          ListTile(
            title: const Text('Confidence threshold'),
            subtitle: Text('${(settings.confidenceThreshold * 100).round()}%'),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                value: settings.confidenceThreshold,
                min: 0.4,
                max: 0.95,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setConfidenceThreshold(v),
              ),
            ),
          ),
          ListTile(
            title: const Text('ML Model'),
            subtitle: Text(
              '${ref.watch(mlServiceProvider).modelName} v${ref.watch(mlServiceProvider).modelVersion}',
            ),
          ),
          _section('Storage'),
          ListTile(
            title: const Text('Saved scans'),
            subtitle: Text('${history.totalScans} items'),
          ),
          ListTile(
            title: const Text('Clear All History'),
            textColor: Colors.red,
            onTap: () => _confirmClear(context, ref),
          ),
          _section('Export'),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export as CSV'),
            onTap: () =>
                ref.read(shareServiceProvider).exportCsv(history.scans),
          ),
          ListTile(
            leading: const Icon(Icons.data_object),
            title: const Text('Export as JSON'),
            onTap: () =>
                ref.read(shareServiceProvider).exportJson(history.scans),
          ),
          _section('About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('v1.0.0 · NumiIT'),
          ),
          ListTile(
            title: const Text('Credits'),
            subtitle: Text(
              'Numismatic AI research — Indian coin inscriptions',
              style: AppTypography.body(12, color: AppColors.textSecondary),
            ),
          ),
          if (isWide)
            const WebFooter()
          else
            const SizedBox(height: 72),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: auth.isAuthenticated
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primaryDark,
                    child: Text(
                      auth.displayName?.isNotEmpty == true
                          ? auth.displayName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName ?? 'Researcher',
                          style: AppTypography.body(15, weight: FontWeight.bold),
                        ),
                        Text(
                          auth.email ?? '',
                          style: AppTypography.body(11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully')),
                      );
                      context.go('/home');
                    },
                    child: const Text('Log Out'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                        foregroundColor: AppColors.accent,
                        child: const Icon(Icons.person_outline, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest Researcher',
                              style: AppTypography.body(15, weight: FontWeight.bold),
                            ),
                            Text(
                              'Log in to sync search history',
                              style: AppTypography.body(11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primaryDark,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          onPressed: () => context.push('/login', extra: '/settings'),
                          child: Text('Sign In', style: AppTypography.body(12, weight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => context.push(
                            '/login',
                            extra: {'redirect': '/settings', 'tab': 1},
                          ),
                          child: Text('Register', style: AppTypography.body(12, weight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: AppTypography.body(12, color: AppColors.textSecondary,
            weight: FontWeight.w600),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(historyProvider.notifier).clearAll();
      await DbHelper.instance.clearAll();
    }
  }
}
