/// EraScore represents a single era's confidence score from the coin model.
/// Negative scores (0%) are included for all non-matching eras.
class EraScore {
  const EraScore({
    required this.era,
    required this.className,
    required this.confidence,
    required this.isPrimary,
    this.dynasty,
    this.transliteration,
    this.translation,
    this.father,
    this.legend,
    this.rules,
  });

  final String era;
  final String className;
  final double confidence;
  final bool isPrimary;
  final String? dynasty;
  final String? transliteration;
  final String? translation;
  final String? father;
  final String? legend;
  final List<String>? rules;

  factory EraScore.fromJson(Map<String, dynamic> json) {
    return EraScore(
      era: json['era'] as String? ?? 'Unknown',
      className: json['class_name'] as String? ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isPrimary: json['is_primary'] as bool? ?? false,
      dynasty: json['dynasty'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      father: json['father'] as String?,
      legend: json['legend'] as String?,
      rules: (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'era': era,
        'class_name': className,
        'confidence': confidence,
        'is_primary': isPrimary,
        'dynasty': dynasty,
        'transliteration': transliteration,
        'translation': translation,
        'father': father,
        'legend': legend,
        'rules': rules,
      };
}
