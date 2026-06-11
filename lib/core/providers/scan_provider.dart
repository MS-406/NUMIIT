import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/detected_region.dart';
import '../models/scan_result.dart';
import 'history_provider.dart';

enum ProcessingStep { preprocess, classify, ocr }

class ScanProcessingState {
  const ScanProcessingState({
    this.step = ProcessingStep.preprocess,
    this.regions = const [],
    this.isComplete = false,
    this.isProcessing = false,
    this.inferenceSeconds,
    this.error,
  });

  final ProcessingStep step;
  final List<DetectedRegion> regions;
  final bool isComplete;
  final bool isProcessing;
  final double? inferenceSeconds;
  final String? error;

  ScanProcessingState copyWith({
    ProcessingStep? step,
    List<DetectedRegion>? regions,
    bool? isComplete,
    bool? isProcessing,
    double? inferenceSeconds,
    String? error,
  }) {
    return ScanProcessingState(
      step: step ?? this.step,
      regions: regions ?? this.regions,
      isComplete: isComplete ?? this.isComplete,
      isProcessing: isProcessing ?? this.isProcessing,
      inferenceSeconds: inferenceSeconds ?? this.inferenceSeconds,
      error: error,
    );
  }
}

class ScanNotifier extends Notifier<ScanProcessingState> {
  @override
  ScanProcessingState build() => const ScanProcessingState();

  Future<ScanResult?> processImage(String imagePath) async {
    state = const ScanProcessingState(isProcessing: true);
    final ml = ref.read(mlServiceProvider);
    final imageService = ref.read(imageServiceProvider);
    final stopwatch = Stopwatch()..start();

    try {
      state = state.copyWith(step: ProcessingStep.preprocess);
      await Future<void>.delayed(const Duration(milliseconds: 600));

      state = state.copyWith(step: ProcessingStep.classify);
      await Future<void>.delayed(const Duration(milliseconds: 400));

      state = state.copyWith(step: ProcessingStep.ocr);
      final regions = await ml.analyzeImage(imagePath);
      stopwatch.stop();

      final thumb = await imageService.ensureThumbnail(imagePath);
      final primary = regions.isEmpty
          ? null
          : regions.reduce(
              (a, b) => a.confidence >= b.confidence ? a : b,
            );

      state = ScanProcessingState(
        step: ProcessingStep.ocr,
        regions: regions,
        isComplete: true,
        isProcessing: false,
        inferenceSeconds: stopwatch.elapsedMilliseconds / 1000,
      );

      if (primary == null) return null;

      final scan = ScanResult(
        imageLocalPath: imagePath,
        imageThumbnailPath: thumb,
        scannedAt: DateTime.now(),
        regions: regions,
        primaryScript: primary.scriptName,
        primaryConfidence: primary.confidence,
      );
      ref.read(currentScanProvider.notifier).state = scan;
      return scan;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ScanProcessingState();
  }
}

final scanProcessingProvider =
    NotifierProvider<ScanNotifier, ScanProcessingState>(ScanNotifier.new);
