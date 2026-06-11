import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ViewfinderOverlay extends StatelessWidget {
  const ViewfinderOverlay({
    super.key,
    this.coinDetected = false,
    this.showGrid = false,
    this.scanLineProgress,
  });

  final bool coinDetected;
  final bool showGrid;
  final double? scanLineProgress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ViewfinderPainter(
        coinDetected: coinDetected,
        showGrid: showGrid,
        scanLineProgress: scanLineProgress,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({
    required this.coinDetected,
    required this.showGrid,
    this.scanLineProgress,
  });

  final bool coinDetected;
  final bool showGrid;
  final double? scanLineProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final cutout = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: size.width * 0.72,
      height: size.width * 0.72,
    );

    final overlayPaint = Paint()
      ..color = (coinDetected ? Colors.green : Colors.black)
          .withValues(alpha: coinDetected ? 0.25 : 0.55);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 1;
      for (var i = 1; i < 3; i++) {
        final x = cutout.left + cutout.width * i / 3;
        canvas.drawLine(Offset(x, cutout.top), Offset(x, cutout.bottom), gridPaint);
        final y = cutout.top + cutout.height * i / 3;
        canvas.drawLine(Offset(cutout.left, y), Offset(cutout.right, y), gridPaint);
      }
    }

    final bracketPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const len = 28.0;
    void corner(Offset o, bool top, bool left) {
      if (top && left) {
        canvas.drawLine(o, o + const Offset(len, 0), bracketPaint);
        canvas.drawLine(o, o + const Offset(0, len), bracketPaint);
      } else if (top && !left) {
        canvas.drawLine(o, o + const Offset(-len, 0), bracketPaint);
        canvas.drawLine(o, o + const Offset(0, len), bracketPaint);
      } else if (!top && left) {
        canvas.drawLine(o, o + const Offset(len, 0), bracketPaint);
        canvas.drawLine(o, o + const Offset(0, -len), bracketPaint);
      } else {
        canvas.drawLine(o, o + const Offset(-len, 0), bracketPaint);
        canvas.drawLine(o, o + const Offset(0, -len), bracketPaint);
      }
    }

    corner(cutout.topLeft, true, true);
    corner(cutout.topRight, true, false);
    corner(cutout.bottomLeft, false, true);
    corner(cutout.bottomRight, false, false);

    if (scanLineProgress != null && !coinDetected) {
      final y = cutout.top + cutout.height * scanLineProgress!.clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(cutout.left, y),
        Offset(cutout.right, y),
        Paint()
          ..color = AppColors.accent
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter old) =>
      old.coinDetected != coinDetected ||
      old.showGrid != showGrid ||
      old.scanLineProgress != scanLineProgress;
}
