import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraControls extends StatelessWidget {
  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onFlip,
    required this.onGallery,
    this.lastThumbnail,
    this.onThumbnailTap,
    this.isCapturing = false,
  });

  final VoidCallback onCapture;
  final VoidCallback onFlip;
  final VoidCallback onGallery;
  final Widget? lastThumbnail;
  final VoidCallback? onThumbnailTap;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Gallery button
          InkWell(
            onTap: onGallery,
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.photo_library, color: Colors.white, size: 22),
            ),
          ),
          // Center: Shutter Capture button
          GestureDetector(
            onTap: isCapturing
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onCapture();
                  },
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Right: History / Last Scan Thumbnail
          GestureDetector(
            onTap: onThumbnailTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: lastThumbnail ??
                  const Center(
                    child: Icon(Icons.history, color: Colors.white, size: 22),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
