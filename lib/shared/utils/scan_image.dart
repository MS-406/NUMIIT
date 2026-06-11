import 'package:flutter/material.dart';

import 'scan_image_platform.dart';

/// Displays a scan image from local path (mobile) or blob/network path (web).
class ScanImage extends StatelessWidget {
  const ScanImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget child = buildScanImage(path, width: width, height: height, fit: fit);

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
