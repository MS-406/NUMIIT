import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ConfidenceUtils {
  static Color badgeBackground(double confidence) {
    if (confidence >= 0.8) return AppColors.confHighBg;
    if (confidence >= 0.6) return AppColors.confMedBg;
    return AppColors.confLowBg;
  }

  static Color badgeTextColor(double confidence) {
    if (confidence >= 0.8) return AppColors.successGreen;
    if (confidence >= 0.6) return AppColors.warningOrange;
    return Colors.red.shade700;
  }

  static String label(double confidence) {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }
}
