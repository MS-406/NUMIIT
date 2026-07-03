import 'detected_region.dart';
import 'era_score.dart';

class ScanResult {
  ScanResult({
    this.id,
    required this.imageLocalPath,
    required this.imageThumbnailPath,
    required this.scannedAt,
    required this.regions,
    required this.primaryScript,
    required this.primaryConfidence,
    this.eraScores = const [],
    this.scanMode = 'coin',
    this.notes,
    this.isSaved = false,
    this.isStarred = false,
    this.userEmail = 'guest',
  });

  final int? id;
  final String imageLocalPath;
  final String imageThumbnailPath;
  final DateTime scannedAt;
  final List<DetectedRegion> regions;
  final String primaryScript;
  final double primaryConfidence;
  final List<EraScore> eraScores;
  final String scanMode;
  final String? notes;
  bool isSaved;
  bool isStarred;
  final String? userEmail;

  String get confidenceLabel =>
      primaryConfidence >= 0.8 ? 'high' : (primaryConfidence >= 0.6 ? 'med' : 'low');

  DetectedRegion? get primaryRegion =>
      regions.isEmpty ? null : regions.first;

  /// Convenience: primary era name from eraScores list.
  String get primaryEra {
    final primary = eraScores.where((e) => e.isPrimary).toList();
    if (primary.isNotEmpty) return primary.first.era;
    if (eraScores.isNotEmpty) return eraScores.first.era;
    return primaryScript;
  }

  ScanResult copyWith({
    int? id,
    String? imageLocalPath,
    String? imageThumbnailPath,
    DateTime? scannedAt,
    List<DetectedRegion>? regions,
    String? primaryScript,
    double? primaryConfidence,
    List<EraScore>? eraScores,
    String? scanMode,
    String? notes,
    bool? isSaved,
    bool? isStarred,
    String? userEmail,
  }) {
    return ScanResult(
      id: id ?? this.id,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      imageThumbnailPath: imageThumbnailPath ?? this.imageThumbnailPath,
      scannedAt: scannedAt ?? this.scannedAt,
      regions: regions ?? this.regions,
      primaryScript: primaryScript ?? this.primaryScript,
      primaryConfidence: primaryConfidence ?? this.primaryConfidence,
      eraScores: eraScores ?? this.eraScores,
      scanMode: scanMode ?? this.scanMode,
      notes: notes ?? this.notes,
      isSaved: isSaved ?? this.isSaved,
      isStarred: isStarred ?? this.isStarred,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
