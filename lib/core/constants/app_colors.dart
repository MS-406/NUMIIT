import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primaryDark = Color(0xFF101633);
  static const Color primaryMid = Color(0xFF182248);
  static const Color accent = Color(0xFFD8B55B);
  static const Color accentAlt = Color(0xFFF4A261);
  static const Color surface = Color(0xFFF8F9FC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF101633);
  static const Color textSecondary = Color(0xFF888888);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFE65100);
  static const Color confHighBg = Color(0xFFE8F5E9);
  static const Color confMedBg = Color(0xFFFFF3E0);
  static const Color confLowBg = Color(0xFFFFEBEE);
  static const Color brahmiBlue = Color(0xFF4A6CF7);

  static const Map<String, Color> scriptColors = {
    'Brahmi': Color(0xFF4A6CF7),
    'Kharoshthi': Color(0xFF9C27B0),
    'Persian': Color(0xFF00897B),
    'Urdu': Color(0xFFE91E63),
    'Arabic': Color(0xFF1565C0),
    'Pali': Color(0xFF6D4C41),
  };

  static Color scriptColor(String script) =>
      scriptColors[script] ?? brahmiBlue;
}
