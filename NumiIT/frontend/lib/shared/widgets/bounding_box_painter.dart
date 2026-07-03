import 'package:flutter/material.dart';
import '../../core/models/detected_region.dart';

class BoundingBoxPainter extends CustomPainter {
  BoundingBoxPainter({
    required this.regions,
    this.selectedIndex,
  });

  final List<DetectedRegion> regions;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    for (int i = 0; i < regions.length; i++) {
      if (selectedIndex != null && selectedIndex != i) {
        continue;
      }

      final region = regions[i];

      // Skip drawing if the region is unidentifiable (dash)
      final trans = region.transliteration.trim();
      if (trans == '—' || trans == '-') {
        continue;
      }

      final rect = Rect.fromLTWH(
        region.boundingBox.left * size.width,
        region.boundingBox.top * size.height,
        region.boundingBox.width * size.width,
        region.boundingBox.height * size.height,
      );

      // Color the box red for clear visibility on the selected region
      final color = Colors.red;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return oldDelegate.regions != regions || oldDelegate.selectedIndex != selectedIndex;
  }
}
