import 'package:flutter/material.dart';
import '../../core/models/scan_result.dart';
import '../../shared/utils/scan_image.dart';
import '../../shared/widgets/bounding_box_painter.dart';

void openFullscreenImage(BuildContext context, ScanResult scan, int selectedIndex) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: CustomPaint(
                foregroundPainter: BoundingBoxPainter(
                  regions: scan.regions,
                  selectedIndex: selectedIndex,
                ),
                child: ScanImage(path: scan.imageLocalPath),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}
