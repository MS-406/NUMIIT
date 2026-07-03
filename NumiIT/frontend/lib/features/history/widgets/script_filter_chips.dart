import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/data/encyclopedia_data.dart';

class ScriptFilterChips extends StatelessWidget {
  const ScriptFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final chips = ['All', ...kAllScripts];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = chips[i];
          final isAll = label == 'All';
          final active = isAll
              ? selected.isEmpty
              : selected.contains(label);
          return FilterChip(
            label: Text(label, style: AppTypography.body(12)),
            selected: active,
            onSelected: (_) {
              if (isAll) {
                onChanged([]);
              } else {
                final next = List<String>.from(selected);
                if (next.contains(label)) {
                  next.remove(label);
                } else {
                  next.add(label);
                }
                onChanged(next);
              }
            },
            backgroundColor: AppColors.surfaceCard,
            selectedColor: AppColors.primaryDark,
            labelStyle: TextStyle(
              color: active ? Colors.white : AppColors.textPrimary,
            ),
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: active ? AppColors.primaryDark : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }
}
