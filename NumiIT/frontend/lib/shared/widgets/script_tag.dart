import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class ScriptTag extends StatelessWidget {
  const ScriptTag({super.key, required this.script, this.small = false});

  final String script;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scriptColor(script);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        script.toUpperCase(),
        style: AppTypography.body(
          small ? 10 : 11,
          color: color,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
