import 'dart:ui';

import '../models/detected_region.dart';

abstract class MLService {
  Future<List<DetectedRegion>> analyzeImage(String imagePath);
  String get modelName => 'stub';
  String get modelVersion => '0.0.0';
}

class MLServiceStub implements MLService {
  @override
  String get modelName => 'NumiIT-Stub';

  @override
  String get modelVersion => '1.0.0-stub';

  @override
  Future<List<DetectedRegion>> analyzeImage(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    return [
      DetectedRegion(
        regionIndex: 0,
        boundingBox: const Rect.fromLTWH(0.1, 0.15, 0.5, 0.25),
        scriptName: 'Brahmi',
        originalText: '𑀫𑀳𑀸𑀭𑀸𑀚',
        transliteration: 'Mahārāja',
        translation: 'Great King',
        dynastyContext: 'Kushan Empire',
        confidence: 0.92,
        glyphCount: 14,
      ),
      DetectedRegion(
        regionIndex: 1,
        boundingBox: const Rect.fromLTWH(0.35, 0.55, 0.45, 0.2),
        scriptName: 'Kharoshthi',
        originalText: '𐨯𐨯𐨪𐨯',
        transliteration: 'Sasa-rasa',
        translation: 'Lord of lords',
        dynastyContext: 'Indo-Scythian',
        confidence: 0.74,
        glyphCount: 8,
      ),
    ];
  }
}
