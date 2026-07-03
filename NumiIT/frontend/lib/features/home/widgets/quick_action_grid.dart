import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/history_provider.dart';

class QuickActionGrid extends ConsumerWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _Action(
        'Gallery Import',
        'Upload image from your phone gallery',
        Icons.photo_library,
        Colors.purple,
        Colors.purple.withValues(alpha: 0.1),
        () async {
          HapticFeedback.lightImpact();
          try {
            final path = await ref.read(imageServiceProvider).pickFromGallery();
            if (path != null && context.mounted) {
              context.push('/detection', extra: path);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to open gallery: Please check storage permissions. ($e)')),
              );
            }
          }
        },
      ),
      _Action(
        'Encyclopedia',
        'Browse 6 historical Indic scripts',
        Icons.menu_book,
        Colors.teal,
        Colors.teal.withValues(alpha: 0.1),
        () => context.push('/encyclopedia'),
      ),
      _Action(
        'Statistics',
        'View script distribution & scans',
        Icons.bar_chart,
        Colors.blue,
        Colors.blue.withValues(alpha: 0.1),
        () => context.push('/statistics'),
      ),
      _Action(
        'Export Data',
        'Export your scan history as CSV',
        Icons.download,
        Colors.orange,
        Colors.orange.withValues(alpha: 0.1),
        () async {
          HapticFeedback.lightImpact();
          final scans = ref.read(historyProvider).scans;
          await ref.read(shareServiceProvider).exportCsv(scans);
        },
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = MediaQuery.sizeOf(context).width < 350;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmall ? 1 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isSmall ? 1.8 : 1.25,
        ),
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final a = actions[i];
          return Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: InkWell(
              onTap: a.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: a.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a.icon, color: a.color, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      a.title,
                      style: AppTypography.body(13, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.desc,
                      style: AppTypography.body(10, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Action {
  _Action(this.title, this.desc, this.icon, this.color, this.bgColor, this.onTap);
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
}
