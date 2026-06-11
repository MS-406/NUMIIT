import 'dart:convert';
import 'dart:ui';

class DetectedRegion {
  const DetectedRegion({
    required this.regionIndex,
    required this.boundingBox,
    required this.scriptName,
    required this.originalText,
    required this.transliteration,
    required this.translation,
    required this.dynastyContext,
    required this.confidence,
    required this.glyphCount,
  });

  final int regionIndex;
  final Rect boundingBox;
  final String scriptName;
  final String originalText;
  final String transliteration;
  final String translation;
  final String dynastyContext;
  final double confidence;
  final int glyphCount;

  Map<String, dynamic> toJson() => {
        'regionIndex': regionIndex,
        'boundingBox': {
          'left': boundingBox.left,
          'top': boundingBox.top,
          'width': boundingBox.width,
          'height': boundingBox.height,
        },
        'scriptName': scriptName,
        'originalText': originalText,
        'transliteration': transliteration,
        'translation': translation,
        'dynastyContext': dynastyContext,
        'confidence': confidence,
        'glyphCount': glyphCount,
      };

  factory DetectedRegion.fromJson(Map<String, dynamic> json) {
    final box = json['boundingBox'] as Map<String, dynamic>;
    return DetectedRegion(
      regionIndex: json['regionIndex'] as int,
      boundingBox: Rect.fromLTWH(
        (box['left'] as num).toDouble(),
        (box['top'] as num).toDouble(),
        (box['width'] as num).toDouble(),
        (box['height'] as num).toDouble(),
      ),
      scriptName: json['scriptName'] as String,
      originalText: json['originalText'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      dynastyContext: json['dynastyContext'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      glyphCount: json['glyphCount'] as int,
    );
  }

  static String encodeList(List<DetectedRegion> regions) =>
      jsonEncode(regions.map((r) => r.toJson()).toList());

  static List<DetectedRegion> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => DetectedRegion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
