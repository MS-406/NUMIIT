import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/history_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/utils/scan_image.dart';
import 'widgets/camera_controls.dart';
import 'widgets/mode_selector.dart';
import 'widgets/viewfinder_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _permissionDenied = false;
  bool _initializing = true;
  bool _capturing = false;
  String _flashMode = 'off';
  CameraMode _mode = CameraMode.single;
  double _zoom = 1.0;
  late AnimationController _scanLineController;
  String? _lastThumbPath;
  bool _showInstructions = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    if (kIsWeb) {
      _initializing = false;
    } else {
      _initCamera();
    }
    _maybeShowInstructions();
  }

  Future<void> _maybeShowInstructions() async {
    final settings = ref.read(settingsProvider);
    if (!settings.cameraInstructionsSeen) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _showInstructions = true;
      });
      ref.read(settingsProvider.notifier).setCameraInstructionsSeen();
      Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showInstructions = false;
          });
        }
      });
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      setState(() => _initializing = false);
      return;
    }

    await _setupController(_cameras.first);
    final recent = await ref.read(historyProvider.notifier).getRecent(limit: 1);
    if (recent.isNotEmpty) {
      setState(() => _lastThumbPath = recent.first.imageThumbnailPath);
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    await _controller?.dispose();
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) {
      setState(() => _initializing = false);
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    final current = _controller?.description;
    final next = _cameras.firstWhere(
      (c) => c != current,
      orElse: () => _cameras.last,
    );
    setState(() => _initializing = true);
    await _setupController(next);
    setState(() => _initializing = false);
  }

  Future<void> _cycleFlash() async {
    final nextMode = switch (_flashMode) {
      'off' => 'on',
      'on' => 'auto',
      _ => 'off',
    };

    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final mappedMode = switch (nextMode) {
          'on' => FlashMode.torch,
          'auto' => FlashMode.auto,
          _ => FlashMode.off,
        };
        await _controller!.setFlashMode(mappedMode);
        setState(() {
          _flashMode = nextMode;
        });
      } catch (e) {
        debugPrint('Flash mode toggle failed: $e');
        setState(() {
          _flashMode = nextMode;
        });
      }
    } else {
      setState(() {
        _flashMode = nextMode;
      });
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _capturing = true);
    try {
      final file = await _controller!.takePicture();
      final imageService = ref.read(imageServiceProvider);
      final saved = await imageService.saveCapturedImage(file.path);
      if (await imageService.isBlurry(saved)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image is blurry, try again'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _capturing = false);
        return;
      }
      HapticFeedback.mediumImpact();
      if (mounted) context.pushReplacement('/detection', extra: saved);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _gallery() async {
    final paths = await ref.read(imageServiceProvider).pickMultipleFromGallery();
    if (paths.isEmpty || !mounted) return;
    if (paths.length == 1) {
      context.pushReplacement('/detection', extra: paths.first);
    } else {
      context.pushReplacement('/detection', extra: paths);
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebGalleryScreen(context);
    }

    if (_permissionDenied) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.no_photography, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  'Camera permission required',
                  style: AppTypography.body(16, color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: openAppSettings,
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_initializing || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _circleBtn(Icons.arrow_back, () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }),
        title: Text(
          'Scan Coin',
          style: AppTypography.body(16, color: Colors.white, weight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          _circleBtn(Icons.flip_camera_android, _flipCamera),
          const SizedBox(width: 8),
          _circleBtn(
            switch (_flashMode) {
              'on' => Icons.flash_on,
              'auto' => Icons.flash_auto,
              _ => Icons.flash_off,
            },
            _cycleFlash,
            color: _flashMode != 'off' ? AppColors.accent : Colors.white,
          ),
          const SizedBox(width: 8),
          _circleBtn(
            settings.gridOverlay ? Icons.grid_on : Icons.grid_off,
            () {
              ref.read(settingsProvider.notifier).setGridOverlay(
                    !settings.gridOverlay,
                  );
            },
            color: settings.gridOverlay ? AppColors.accent : Colors.white,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: (d) {
              final point = d.localPosition;
              _controller!.setFocusPoint(
                Offset(
                  point.dx / MediaQuery.sizeOf(context).width,
                  point.dy / MediaQuery.sizeOf(context).height,
                ),
              );
            },
            onScaleUpdate: (d) {
              setState(() {
                _zoom = (_zoom * d.scale).clamp(0.5, 3.0);
              });
              _controller!.setZoomLevel(_zoom);
            },
            child: CameraPreview(_controller!),
          ),
          AnimatedBuilder(
            animation: _scanLineController,
            builder: (_, __) => ViewfinderOverlay(
              showGrid: settings.gridOverlay,
              scanLineProgress: _scanLineController.value,
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Position coin within frame',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
                ModeSelector(
                  selected: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
                CameraControls(
                  isCapturing: _capturing,
                  onCapture: _capture,
                  onFlip: _flipCamera,
                  onGallery: _gallery,
                  onThumbnailTap: () => context.go('/history'),
                  lastThumbnail: _lastThumbPath != null
                      ? ScanImage(
                          path: _lastThumbPath!,
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(24),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (_showInstructions)
            Positioned(
              top: kIsWeb ? 80 : 100,
              left: 16,
              right: 16,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Card(
                  color: Colors.black.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Hold steady · Good lighting · Fill the frame',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                          onPressed: () {
                            setState(() {
                              _showInstructions = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebGalleryScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Import Coin Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'Camera is not available in the browser.\nUse gallery import to scan a coin.',
              textAlign: TextAlign.center,
              style: AppTypography.body(14, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _gallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick from Gallery'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 22),
      ),
    );
  }
}
