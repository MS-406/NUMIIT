import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/history_provider.dart';
import '../../../shared/widgets/ghost_button.dart';
import '../../../shared/widgets/gold_button.dart';

class ScanHeroCard extends ConsumerWidget {
  const ScanHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative background rings
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.04),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: 60,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.02),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-POWERED NUMISMATIC RESEARCH',
                    style: AppTypography.body(
                      10,
                      color: AppColors.accent,
                      weight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Decode Ancient Coin\nInscriptions Instantly',
                    style: AppTypography.display(
                      24,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ).copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upload or scan any ancient Indian coin and our ML engine identifies the script, transliterates, and translates inscriptions from 6 historical writing systems.',
                    style: AppTypography.body(12, color: Colors.white70).copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 200;
                      if (isSmall) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: GoldButton(
                                label: 'Scan Coin',
                                icon: Icons.camera_alt,
                                onTap: () => context.push('/camera'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: GhostButton(
                                label: 'History',
                                onTap: () => context.push('/history'),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: GoldButton(
                              label: 'Scan Coin',
                              icon: Icons.camera_alt,
                              onTap: () => context.push('/camera'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GhostButton(
                              label: 'History',
                              onTap: () => context.push('/history'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.white12,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('6', 'Scripts'),
                      _statItem('<3s', 'Speed'),
                      _statItem('${history.scansThisWeek}', 'Scans/Wk'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.display(
            18,
            color: AppColors.accent,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.body(
            9,
            color: Colors.white54,
            weight: FontWeight.w600,
          ).copyWith(letterSpacing: 0.5),
        ),
      ],
    );
  }
}
