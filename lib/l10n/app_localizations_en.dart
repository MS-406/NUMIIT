// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NumiIT';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get browseHistory => 'Browse History';

  @override
  String get detectingScript => 'Detecting script regions...';

  @override
  String get translationResult => 'Translation Result';

  @override
  String get saveToHistory => 'Save to History';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get confidence => 'Confidence';

  @override
  String get detectedScript => 'Detected Script';

  @override
  String get originalInscription => 'Original Inscription';

  @override
  String get transliteration => 'Transliteration';

  @override
  String get englishTranslation => 'English Translation';

  @override
  String get scanACoin => 'Scan a Coin';

  @override
  String get helloResearcher => 'Hello, Researcher';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get settings => 'Settings';

  @override
  String get noScansYet => 'No scans yet. Tap Scan Now to start!';

  @override
  String get analyzingInscription => 'Analyzing Inscription';

  @override
  String get translateAllRegions => 'Translate All Regions';

  @override
  String get gotIt => 'Got It';

  @override
  String get onboardingTitle1 => 'Scan';

  @override
  String get onboardingDesc1 =>
      'Capture ancient coin inscriptions with your camera';

  @override
  String get onboardingTitle2 => 'Detect';

  @override
  String get onboardingDesc2 =>
      'AI identifies script regions and bounding boxes';

  @override
  String get onboardingTitle3 => 'Translate';

  @override
  String get onboardingDesc3 =>
      'Get transliteration and English translation instantly';
}
