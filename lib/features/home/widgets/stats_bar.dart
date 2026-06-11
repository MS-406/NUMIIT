import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/history_provider.dart';
import '../../../shared/widgets/animated_counter.dart';

class StatsBar extends ConsumerWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _stat(
              'Total Scans',
              AnimatedCounter(value: history.totalScans),
            ),
          ),
          Expanded(
            child: _stat(
              'Scripts',
              AnimatedCounter(value: history.scriptsDetected),
            ),
          ),
          Expanded(
            child: _stat(
              'This Week',
              AnimatedCounter(value: history.scansThisWeek),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, Widget value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          value,
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.body(10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
