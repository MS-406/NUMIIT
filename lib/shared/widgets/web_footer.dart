import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;
    if (!isWide) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.primaryDark : const Color(0xFFF0F2F5),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NumiIT',
                          style: AppTypography.display(
                            18,
                            color: AppColors.accent,
                            weight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI-driven ancient Indic inscription translation and historical numismatics portal.',
                      style: AppTypography.body(12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),

              // Navigation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NAVIGATION',
                      style: AppTypography.body(11,
                          color: AppColors.accent, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _footerLink(context, 'Dashboard', '/home'),
                    _footerLink(context, 'Scan History', '/history'),
                    _footerLink(context, 'Encyclopedia', '/encyclopedia'),
                    _footerLink(context, 'Statistics', '/statistics'),
                  ],
                ),
              ),

              // About
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESOURCES',
                      style: AppTypography.body(11,
                          color: AppColors.accent, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _footerLink(context, 'Settings & Tools', '/settings'),
                    Text(
                      'Version 1.0.0',
                      style: AppTypography.body(12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Credits: Archaeological AI Research',
                      style: AppTypography.body(11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 NumiIT Research Project. All rights reserved.',
                style: AppTypography.body(11, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  Text(
                    'Archaeological Heritage preservation',
                    style: AppTypography.body(11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.shield, color: AppColors.accent, size: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go(route),
          child: Text(
            label,
            style: AppTypography.body(12,
                color: AppColors.textSecondary, weight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
