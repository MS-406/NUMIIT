import '../models/coin_inscription.dart';

const kEncyclopediaEntries = [
  CoinInscription(
    scriptName: 'Brahmi',
    nativeName: 'ब्राह्मी',
    historicalPeriod: '3rd century BCE – 5th century CE',
    sampleText: '𑀫𑀳𑀸𑀭𑀸𑀚',
    sampleTranslation: 'Great King (Mahārāja)',
    unicodeBlock: 'U+11000 – U+1107F',
  ),
  CoinInscription(
    scriptName: 'Kharoshthi',
    nativeName: 'खरोष्ठी',
    historicalPeriod: '3rd century BCE – 3rd century CE',
    sampleText: '𐨯𐨯𐨪𐨯',
    sampleTranslation: 'Lord of lords',
    unicodeBlock: 'U+10A00 – U+10A5F',
  ),
  CoinInscription(
    scriptName: 'Persian',
    nativeName: 'فارسی',
    historicalPeriod: 'Achaemenid – Mughal periods',
    sampleText: 'شاهنشاه',
    sampleTranslation: 'King of Kings',
    unicodeBlock: 'U+0600 – U+06FF',
  ),
  CoinInscription(
    scriptName: 'Urdu',
    nativeName: 'اردو',
    historicalPeriod: 'Mughal – Colonial',
    sampleText: 'بادشاہ',
    sampleTranslation: 'Emperor',
    unicodeBlock: 'U+0600 – U+06FF (Nastaliq)',
  ),
  CoinInscription(
    scriptName: 'Arabic',
    nativeName: 'العربية',
    historicalPeriod: 'Delhi Sultanate – Mughal',
    sampleText: 'السلطان',
    sampleTranslation: 'The Sultan',
    unicodeBlock: 'U+0600 – U+06FF',
  ),
  CoinInscription(
    scriptName: 'Pali',
    nativeName: 'पालि',
    historicalPeriod: 'Mauryan – Buddhist kingdoms',
    sampleText: 'देवानंपिय',
    sampleTranslation: 'Beloved of the Gods',
    unicodeBlock: 'Brahmi-derived Indic',
  ),
];

const kAllScripts = [
  'Brahmi',
  'Kharoshthi',
  'Persian',
  'Urdu',
  'Arabic',
  'Pali',
];
