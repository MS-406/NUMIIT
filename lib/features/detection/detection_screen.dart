import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/history_provider.dart';
import '../../core/providers/scan_provider.dart';
import '../../shared/widgets/ghost_button.dart';
import '../../shared/widgets/gold_button.dart';
import 'widgets/bounding_box_overlay.dart';
import 'widgets/detection_card.dart';
import 'widgets/processing_steps.dart';

class DetectionScreen extends ConsumerStatefulWidget {
  const DetectionScreen({
    super.key,
    this.imagePath = '',
    this.imagePaths,
  });

  final String imagePath;
  final List<String>? imagePaths;

  @override
  ConsumerState<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends ConsumerState<DetectionScreen> {
  String? _activePath;
  int _queueIndex = 0;
  bool _started = false;

  List<String> get _paths {
    if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty) {
      return widget.imagePaths!;
    }
    if (widget.imagePath.isNotEmpty) return [widget.imagePath];
    return [];
  }

  @override
  void initState() {
    super.initState();
    _activePath = _paths.isNotEmpty ? _paths.first : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnalysis());
  }

  Future<void> _runAnalysis() async {
    if (_started || _activePath == null) return;
    _started = true;
    ref.read(scanProcessingProvider.notifier).reset();
    final scan = await ref
        .read(scanProcessingProvider.notifier)
        .processImage(_activePath!);

    if (!mounted) return;

    final state = ref.read(scanProcessingProvider);
    if (scan == null && state.regions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No inscription detected')),
      );
      return;
    }

    if (state.regions.every((r) => r.confidence < 0.6)) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Low confidence'),
          content: const Text(
            'Low confidence detected. Results may be inaccurate. Proceed or retake?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Retake')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Proceed')),
          ],
        ),
      );
      if (proceed != true && mounted) {
        context.pop();
      }
    }

    if (scan != null) {
      HapticFeedback.mediumImpact();
    }
  }

  void _translate() {
    final scan = ref.read(currentScanProvider);
    if (scan != null) {
      context.pushReplacement('/result', extra: scan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final processing = ref.watch(scanProcessingProvider);
    final paths = _paths;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Analyzing Inscription'),
      ),
      body: _activePath == null
          ? const Center(child: Text('No image provided'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (paths.length > 1)
                    Text(
                      'Batch ${ _queueIndex + 1} of ${paths.length}',
                      style: AppTypography.body(12, color: AppColors.textSecondary),
                    ),
                  BoundingBoxOverlay(
                    imagePath: _activePath!,
                    regions: processing.regions,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ProcessingSteps(
                    currentStep: processing.step,
                    isComplete: processing.isComplete,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...processing.regions.asMap().entries.map(
                        (e) => DetectionCard(
                          region: e.value,
                          delayMs: e.key * 80,
                        ),
                      ),
                  if (processing.inferenceSeconds != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Analysis complete in ${processing.inferenceSeconds!.toStringAsFixed(1)}s',
                        style: AppTypography.body(12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  GoldButton(
                    label: 'Translate All Regions →',
                    onTap: processing.isComplete ? _translate : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: GhostButton(
                      label: 'Cancel / Retake',
                      light: false,
                      onTap: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
