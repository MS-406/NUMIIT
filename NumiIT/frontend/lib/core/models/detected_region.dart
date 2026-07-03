import 'dart:convert';
import 'dart:ui';

class DetectedRegion {
  const DetectedRegion({
    required this.regionIndex,
    required this.boundingBox,
    required this.scriptName,
    required this.originalText,
    this.fontChar = '',
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
  final String fontChar;
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
        'fontChar': fontChar,
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
      fontChar: (json['fontChar'] as String?)?.isNotEmpty == true 
          ? json['fontChar'] as String 
          : _fallbackFontMap[json['originalText'] as String] ?? '',
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      dynastyContext: json['dynastyContext'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      glyphCount: json['glyphCount'] as int,
    );
  }

  static const _fallbackFontMap = <String, String>{
    '𑀤': 'A',
    '𑀤𑁆𑀭': 'B',
    '𑀳': 'C',
    '𑀚𑁆𑀜𑀂': 'D',
    '𑀚𑁆𑀜𑁄': 'E',
    '𑀓𑁆𑀱': 'F',
    '𑀫': 'G',
    '𑀦': 'H',
    '𑀧': 'I',
    '𑀧𑀼': 'J',
    '𑀭': 'K',
    '𑀭𑀼': 'L',
    '𑀲': 'M',
    '𑀲𑁂': 'M',
    '𑀢𑁆𑀭': 'N',
    '𑀯𑀺': 'O',
  };

  static String encodeList(List<DetectedRegion> regions) =>
      jsonEncode(regions.map((r) => r.toJson()).toList());

  static List<DetectedRegion> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => DetectedRegion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
