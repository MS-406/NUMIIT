import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_io/io.dart';
import 'package:dio/dio.dart' as dio_lib;

import '../models/detected_region.dart';
import '../models/era_score.dart';
import '../providers/scan_provider.dart';
import 'api_service.dart';
import 'dio_client.dart';

/// Container for the full ML response (regions + era scores).
class MLAnalysisResult {
  const MLAnalysisResult({
    required this.regions,
    this.eraScores = const [],
    this.scanMode = 'coin',
    this.primaryConfidence = 0.0,
  });

  final List<DetectedRegion> regions;
  final List<EraScore> eraScores;
  final String scanMode;
  final double primaryConfidence;
}

abstract class MLService {
  Future<MLAnalysisResult> analyzeImage(String imagePath, {ScanMode mode});
  String? get lastUploadedImagePath;
  String? get lastUploadedThumbnailPath;
  String get modelName;
  String get modelVersion;
}

class MLServiceStub implements MLService {
  @override
  String get modelName => 'NumiIT-Stub';

  @override
  String get modelVersion => '1.0.0-stub';

  @override
  String? get lastUploadedImagePath => null;

  @override
  String? get lastUploadedThumbnailPath => null;

  @override
  Future<MLAnalysisResult> analyzeImage(String imagePath, {ScanMode mode = ScanMode.coin}) async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    return _getMockResult(mode);
  }
}

MLAnalysisResult _getMockResult(ScanMode mode) {
  return MLAnalysisResult(
    scanMode: mode == ScanMode.character ? 'character' : 'coin',
    eraScores: [
      const EraScore(
        era: 'Unknown / Not Available',
        className: 'unknown',
        confidence: 0.0,
        isPrimary: true,
      ),
    ],
    regions: [],
  );
}

class DioMLService implements MLService {
  DioMLService(this._ref);

  final Ref _ref;
  String? _lastUploadedImagePath;
  String? _lastUploadedThumbnailPath;

  @override
  String get modelName => 'NumiIT-Backend-ML';

  @override
  String get modelVersion => '2.0.0';

  @override
  String? get lastUploadedImagePath => _lastUploadedImagePath;

  @override
  String? get lastUploadedThumbnailPath => _lastUploadedThumbnailPath;

  String _resolveAbsoluteUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final baseUrl = getEffectiveBaseUrl();
    final uri = Uri.parse(baseUrl);
    final portPart = uri.hasPort ? ':${uri.port}' : '';
    final origin = '${uri.scheme}://${uri.host}$portPart';
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$origin$cleanPath';
  }

  @override
  Future<MLAnalysisResult> analyzeImage(
    String imagePath, {
    ScanMode mode = ScanMode.coin,
  }) async {
    _lastUploadedImagePath = null;
    _lastUploadedThumbnailPath = null;

    List<int>? fileBytes;
    String? fileName;

    try {
      if (kIsWeb) {
        if (imagePath.startsWith('blob:') || imagePath.startsWith('http')) {
          final response = await dio_lib.Dio().get<List<int>>(
            imagePath,
            options: dio_lib.Options(responseType: dio_lib.ResponseType.bytes),
          );
          fileBytes = response.data;
          fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          fileBytes = await file.readAsBytes();
          fileName = file.uri.pathSegments.last;
        }
      }

      if (fileBytes == null) {
        return MLAnalysisResult(
          scanMode: mode == ScanMode.character ? 'character' : 'coin',
          eraScores: [
            const EraScore(
              era: 'Unknown / Other Era',
              className: 'unknown',
              confidence: 0.0,
              isPrimary: true,
            ),
          ],
          regions: [],
        );
      }

      final apiService = _ref.read(apiServiceProvider);
      final modeStr = mode == ScanMode.character ? 'character' : 'coin';

      final response = await apiService.uploadImage(
        filePath: imagePath,
        bytes: fileBytes,
        fileName: fileName,
        mode: modeStr,
      );

      final rawImagePath = response['image_path'] as String? ?? '';
      final rawThumbPath = response['thumbnail_path'] as String? ?? '';

      _lastUploadedImagePath = _resolveAbsoluteUrl(rawImagePath);
      _lastUploadedThumbnailPath = _resolveAbsoluteUrl(rawThumbPath);

      // Parse era_scores
      final eraScoresList = response['era_scores'] as List<dynamic>? ?? [];
      final eraScores = eraScoresList
          .map((e) => EraScore.fromJson(e as Map<String, dynamic>))
          .toList();

      // Parse regions
      final regionsList = response['regions'] as List<dynamic>? ?? [];
      final regions = regionsList
          .map((e) => DetectedRegion.fromJson(e as Map<String, dynamic>))
          .toList();

      final scanModeStr = response['scan_mode'] as String? ?? modeStr;
      final apiPrimaryConfidence = (response['primary_confidence'] as num?)?.toDouble() ?? 0.0;

      return MLAnalysisResult(
        regions: regions,
        eraScores: eraScores,
        scanMode: scanModeStr,
        primaryConfidence: apiPrimaryConfidence,
      );
    } catch (e) {
      if (kDebugMode) {
        print('ML Service upload analysis error: $e');
      }
      return MLAnalysisResult(
        scanMode: mode == ScanMode.character ? 'character' : 'coin',
        eraScores: [
          const EraScore(
            era: 'Unknown / Other Era',
            className: 'unknown',
            confidence: 0.0,
            isPrimary: true,
          ),
        ],
        regions: [],
      );
    }
  }
}
