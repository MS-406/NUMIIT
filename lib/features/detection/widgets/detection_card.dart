import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/detected_region.dart';
import '../../result/widgets/confidence_bar.dart';

class DetectionCard extends StatelessWidget {
  const DetectionCard({super.key, required this.region, this.delayMs = 0});

  final DetectedRegion region;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final conf = region.confidence;
    final color = conf >= 0.8
        ? AppColors.successGreen
        : (conf >= 0.6 ? AppColors.warningOrange : Colors.red);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('📜', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.scriptName,
                        style: AppTypography.body(14, weight: FontWeight.bold),
                      ),
                      Text(
                        'Region ${region.regionIndex + 1} · ${region.glyphCount} glyphs',
                        style: AppTypography.body(11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(conf * 100).round()}%',
                  style: AppTypography.body(13, color: color, weight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConfidenceBar(confidence: conf),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.2, end: 0, duration: 300.ms, delay: delayMs.ms)
        .fadeIn(delay: delayMs.ms);
  }
}
