import 'package:flutter/widgets.dart';

import '../models/translation_language.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// 현재 화면 언어의 문구. 위젯 테스트처럼 지역화 설정이 없는 트리에서는 한국어를 쓴다.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('ko'));
}

/// 앱 화면 언어. 번역 언어를 직접 골랐으면 그 언어, 자동이면 null(기기 언어).
Locale? appLocaleFor(TranslationLanguage? translationLanguage) =>
    translationLanguage == null ? null : Locale(translationLanguage.code);

/// 위젯 밖(알림·서비스)에서 쓸 문구. 지원하지 않는 언어는 영어로 대체한다.
AppLocalizations l10nFor(Locale? locale) {
  final resolved = locale ?? WidgetsBinding.instance.platformDispatcher.locale;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == resolved.languageCode,
  );
  return lookupAppLocalizations(
    supported ? Locale(resolved.languageCode) : const Locale('en'),
  );
}

extension AppLocalizationsHelpers on AppLocalizations {
  String language(TranslationLanguage language) => languageName(language.code);

  /// 1=월 … 7=일.
  String weekday(int day) => weekdayShort('d$day');
}

/// 품사 표시용. 저장 값(한국어 품사명)은 그대로 두고 화면 언어로만 바꿔 보여준다.
extension WordPartOfSpeechL10n on AppLocalizations {
  static const _keys = {
    '명사': 'noun',
    '동사': 'verb',
    '형용사': 'adjective',
    '부사': 'adverb',
    '대명사': 'pronoun',
    '전치사': 'preposition',
    '접속사': 'conjunction',
    '감탄사': 'interjection',
    '관사': 'article',
    '한정사': 'determiner',
    '구동사': 'phrasalVerb',
    '숙어': 'idiom',
    '관용구': 'idiom',
    '구': 'phrase',
    // 영어로 저장된 값
    'noun': 'noun',
    'verb': 'verb',
    'adjective': 'adjective',
    'adj': 'adjective',
    'adverb': 'adverb',
    'adv': 'adverb',
    'pronoun': 'pronoun',
    'preposition': 'preposition',
    'conjunction': 'conjunction',
    'interjection': 'interjection',
    'article': 'article',
    'determiner': 'determiner',
    'phrasal verb': 'phrasalVerb',
    'idiom': 'idiom',
    'phrase': 'phrase',
  };

  String partOfSpeech(String value) => wordPartOfSpeech(
    _keys[value.trim().toLowerCase()] ?? _keys[value] ?? 'other',
    value,
  );
}
