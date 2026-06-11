// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'NumiIT';

  @override
  String get scanNow => 'अभी स्कैन करें';

  @override
  String get browseHistory => 'इतिहास देखें';

  @override
  String get detectingScript => 'लिपि क्षेत्रों का पता लगाया जा रहा है...';

  @override
  String get translationResult => 'अनुवाद परिणाम';

  @override
  String get saveToHistory => 'इतिहास में सहेजें';

  @override
  String get scanAgain => 'फिर से स्कैन करें';

  @override
  String get confidence => 'विश्वास';

  @override
  String get detectedScript => 'पहचानी गई लिपि';

  @override
  String get originalInscription => 'मूल शिलालेख';

  @override
  String get transliteration => 'लिप्यंतरण';

  @override
  String get englishTranslation => 'अंग्रेजी अनुवाद';

  @override
  String get scanACoin => 'सिक्का स्कैन करें';

  @override
  String get helloResearcher => 'नमस्ते, शोधकर्ता';

  @override
  String get scanHistory => 'स्कैन इतिहास';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get noScansYet =>
      'अभी तक कोई स्कैन नहीं। शुरू करने के लिए स्कैन करें!';

  @override
  String get analyzingInscription => 'शिलालेख का विश्लेषण';

  @override
  String get translateAllRegions => 'सभी क्षेत्रों का अनुवाद';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get onboardingTitle1 => 'स्कैन';

  @override
  String get onboardingDesc1 =>
      'अपने कैमरे से प्राचीन सिक्के के शिलालेख कैप्चर करें';

  @override
  String get onboardingTitle2 => 'पहचान';

  @override
  String get onboardingDesc2 => 'AI लिपि क्षेत्रों की पहचान करता है';

  @override
  String get onboardingTitle3 => 'अनुवाद';

  @override
  String get onboardingDesc3 =>
      'तुरंत लिप्यंतरण और अंग्रेजी अनुवाद प्राप्त करें';
}
