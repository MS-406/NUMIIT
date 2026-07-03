import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/detected_region.dart';
import '../../../shared/utils/scan_image.dart';

class BoundingBoxOverlay extends StatelessWidget {
  const BoundingBoxOverlay({
    super.key,
    required this.imagePath,
    required this.regions,
    this.height = 300,
  });

  final String imagePath;
  final List<DetectedRegion> regions;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ScanImage(path: imagePath, fit: BoxFit.cover),
            ...regions.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              return _BBox(
                region: r,
                index: i,
              )
                  .animate()
                  .fadeIn(duration: 200.ms, delay: (300 * i).ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 200.ms,
                    delay: (300 * i).ms,
                  );
            }),
          ],
        ),
      ),
    );
  }
}

class _BBox extends StatelessWidget {
  const _BBox({required this.region, required this.index});

  final DetectedRegion region;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = region.boundingBox;
        return Positioned(
          left: box.left * constraints.maxWidth,
          top: box.top * constraints.maxHeight,
          width: box.width * constraints.maxWidth,
          height: box.height * constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned(
                left: 0,
                top: -22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Region ${region.regionIndex + 1} — ${region.scriptName}',
                    style: AppTypography.body(10, color: AppColors.primaryDark,
                        weight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
