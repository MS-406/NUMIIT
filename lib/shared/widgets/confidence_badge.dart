import 'package:flutter/material.dart';

import '../../core/constants/app_typography.dart';
import '../utils/confidence_utils.dart';

class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ConfidenceUtils.badgeBackground(confidence),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${(confidence * 100).round()}%',
        style: AppTypography.body(
          11,
          color: ConfidenceUtils.badgeTextColor(confidence),
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
