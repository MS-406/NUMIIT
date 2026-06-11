import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/detected_region.dart';

class TransliterationTab extends StatelessWidget {
  const TransliterationTab({super.key, required this.region});

  final DetectedRegion region;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            region.transliteration,
            style: AppTypography.display(36, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pronunciation guide',
            style: AppTypography.body(12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 4),
          Text(
            'IPA: /${region.transliteration.toLowerCase()}/',
            style: AppTypography.body(14, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Script family',
            style: AppTypography.body(12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          Text(
            '${region.scriptName} — ancient Indic numismatic script',
            style: AppTypography.body(14, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
