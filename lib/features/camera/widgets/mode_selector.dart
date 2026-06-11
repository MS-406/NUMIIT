import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

enum CameraMode { single, batch }

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CameraMode selected;
  final ValueChanged<CameraMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Single Coin tab
            GestureDetector(
              onTap: () => onChanged(CameraMode.single),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: selected == CameraMode.single ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Single Coin',
                  style: AppTypography.body(
                    12,
                    color: selected == CameraMode.single
                        ? AppColors.primaryDark
                        : (isDark ? Colors.white70 : AppColors.textPrimary),
                    weight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Batch Scan tab (Disabled / Coming soon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Batch Scan',
                    style: AppTypography.body(
                      12,
                      color: isDark ? Colors.white30 : Colors.black38,
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Soon',
                      style: AppTypography.body(8, color: isDark ? Colors.white54 : Colors.black45, weight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
