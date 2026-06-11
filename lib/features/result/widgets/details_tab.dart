import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/detected_region.dart';

class DetailsTab extends StatelessWidget {
  const DetailsTab({super.key, required this.region});

  final DetectedRegion region;

  @override
  Widget build(BuildContext context) {
    final chars = region.originalText.characters.toList();
    if (chars.isEmpty) {
      return Center(
        child: Text(
          'Detailed glyph data coming soon',
          style: AppTypography.body(14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chars.length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: Text(chars[i], style: AppTypography.script(24, color: Theme.of(context).colorScheme.onSurface)),
          title: Text('Glyph ${i + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text('Romanization: ${chars[i]}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        );
      },
    );
  }
}
