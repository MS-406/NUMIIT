class CoinInscription {
  const CoinInscription({
    required this.scriptName,
    required this.nativeName,
    required this.historicalPeriod,
    required this.sampleText,
    required this.sampleTranslation,
    required this.unicodeBlock,
  });

  final String scriptName;
  final String nativeName;
  final String historicalPeriod;
  final String sampleText;
  final String sampleTranslation;
  final String unicodeBlock;
}
