import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/detected_region.dart';
import '../models/era_score.dart';
import '../models/scan_result.dart';
import 'history_provider.dart';

enum ProcessingStep { preprocess, classify, ocr }

/// The scan mode selected by the user before scanning.
enum ScanMode { coin, character }

class ScanProcessingState {
  const ScanProcessingState({
    this.step = ProcessingStep.preprocess,
    this.regions = const [],
    this.eraScores = const [],
    this.scanMode = ScanMode.coin,
    this.isComplete = false,
    this.isProcessing = false,
    this.inferenceSeconds,
    this.error,
  });

  final ProcessingStep step;
  final List<DetectedRegion> regions;
  final List<EraScore> eraScores;
  final ScanMode scanMode;
  final bool isComplete;
  final bool isProcessing;
  final double? inferenceSeconds;
  final String? error;

  ScanProcessingState copyWith({
    ProcessingStep? step,
    List<DetectedRegion>? regions,
    List<EraScore>? eraScores,
    ScanMode? scanMode,
    bool? isComplete,
    bool? isProcessing,
    double? inferenceSeconds,
    String? error,
  }) {
    return ScanProcessingState(
      step: step ?? this.step,
      regions: regions ?? this.regions,
      eraScores: eraScores ?? this.eraScores,
      scanMode: scanMode ?? this.scanMode,
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

  Future<ScanResult?> processImage(String imagePath, {ScanMode mode = ScanMode.coin}) async {
    state = ScanProcessingState(isProcessing: true, scanMode: mode);
    final ml = ref.read(mlServiceProvider);
    final imageService = ref.read(imageServiceProvider);
    final stopwatch = Stopwatch()..start();

    try {
      state = state.copyWith(step: ProcessingStep.preprocess);
      await Future<void>.delayed(const Duration(milliseconds: 600));

      state = state.copyWith(step: ProcessingStep.classify);
      await Future<void>.delayed(const Duration(milliseconds: 400));

      state = state.copyWith(step: ProcessingStep.ocr);
      final result = await ml.analyzeImage(imagePath, mode: mode);
      stopwatch.stop();

      final thumb = await imageService.ensureThumbnail(imagePath);
      final regions = result.regions;
      final eraScores = result.eraScores;

      final primary = regions.isEmpty
          ? null
          : regions.reduce(
              (a, b) => a.confidence >= b.confidence ? a : b,
            );

      state = ScanProcessingState(
        step: ProcessingStep.ocr,
        regions: regions,
        eraScores: eraScores,
        scanMode: mode,
        isComplete: true,
        isProcessing: false,
        inferenceSeconds: stopwatch.elapsedMilliseconds / 1000,
      );

      if (primary == null) return null;

      final remoteImagePath = ml.lastUploadedImagePath ?? imagePath;
      final remoteThumbPath = ml.lastUploadedThumbnailPath ?? thumb;

      final scan = ScanResult(
        imageLocalPath: remoteImagePath,
        imageThumbnailPath: remoteThumbPath,
        scannedAt: DateTime.now(),
        regions: regions,
        eraScores: eraScores,
        scanMode: mode.name,
        primaryScript: primary.scriptName,
        primaryConfidence: result.primaryConfidence,
      );
      
      // Auto-save to history
      final id = await ref.read(historyProvider.notifier).saveScan(scan);
      final savedScan = scan.copyWith(id: id, isSaved: true);
      
      ref.read(currentScanProvider.notifier).state = savedScan;
      return savedScan;
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
