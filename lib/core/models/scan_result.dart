import 'detected_region.dart';

class ScanResult {
  ScanResult({
    this.id,
    required this.imageLocalPath,
    required this.imageThumbnailPath,
    required this.scannedAt,
    required this.regions,
    required this.primaryScript,
    required this.primaryConfidence,
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
  final String? notes;
  bool isSaved;
  bool isStarred;
  final String? userEmail;

  String get confidenceLabel =>
      primaryConfidence >= 0.8 ? 'high' : (primaryConfidence >= 0.6 ? 'med' : 'low');

  DetectedRegion? get primaryRegion =>
      regions.isEmpty ? null : regions.first;

  ScanResult copyWith({
    int? id,
    String? imageLocalPath,
    String? imageThumbnailPath,
    DateTime? scannedAt,
    List<DetectedRegion>? regions,
    String? primaryScript,
    double? primaryConfidence,
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
      notes: notes ?? this.notes,
      isSaved: isSaved ?? this.isSaved,
      isStarred: isStarred ?? this.isStarred,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

