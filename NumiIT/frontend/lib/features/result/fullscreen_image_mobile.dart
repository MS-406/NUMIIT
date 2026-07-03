import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/models/scan_result.dart';
import '../../shared/utils/scan_image.dart';
import '../../shared/widgets/bounding_box_painter.dart';

void openFullscreenImage(BuildContext context, ScanResult scan, int selectedIndex) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: InteractiveViewer(
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
      ),
    ),
  );
}
