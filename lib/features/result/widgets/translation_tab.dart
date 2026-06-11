import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/detected_region.dart';
import 'confidence_bar.dart';

class TranslationTab extends StatelessWidget {
  const TranslationTab({super.key, required this.region});

  final DetectedRegion region;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (region.confidence < 0.6)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.confMedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                'Results may be inaccurate',
                style: AppTypography.body(13, color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
        _field(context, 'Detected Script', region.scriptName),
        _field(context, 'Original Inscription', region.originalText,
            isScript: true),
        _field(context, 'Transliteration', region.transliteration),
        _field(context, 'English Translation', region.translation),
        _field(context, 'Dynasty Context', region.dynastyContext),
        _field(
          context,
          'Confidence',
          '${(region.confidence * 100).round()}%',
          trailing: ConfidenceBar(confidence: region.confidence),
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    String value, {
    bool isScript = false,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied $label')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.body(11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), weight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              if (trailing != null) trailing else
                Text(
                  value,
                  style: isScript
                      ? AppTypography.script(22)
                      : AppTypography.body(15, weight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
