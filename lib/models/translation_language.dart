import 'dart:ui' show Locale;

enum TranslationLanguage {
  korean('ko', 'kor', '한국어', {'KR'}),
  english('en', 'eng', '영어', {'US', 'GB', 'AU', 'CA', 'NZ', 'IE'}),
  japanese('ja', 'jpn', '일본어', {'JP'}),
  chinese('zh', 'cmn', '중국어', {'CN', 'TW', 'HK', 'MO'}),
  spanish('es', 'spa', '스페인어', {
    'ES',
    'MX',
    'AR',
    'CO',
    'CL',
    'PE',
    'VE',
    'EC',
    'GT',
    'CU',
    'BO',
    'DO',
    'HN',
    'PY',
    'SV',
    'NI',
    'CR',
    'PA',
    'UY',
  }),
  french('fr', 'fra', '프랑스어', {'FR', 'BE', 'MC'}),
  german('de', 'deu', '독일어', {'DE', 'AT', 'LI'}),
  portuguese('pt', 'por', '포르투갈어', {'PT', 'BR', 'AO', 'MZ'}),
  vietnamese('vi', 'vie', '베트남어', {'VN'}),
  thai('th', 'tha', '태국어', {'TH'}),
  indonesian('id', 'ind', '인도네시아어', {'ID'});

  final String code;
  final String tatoebaCode;
  final String label;

  /// Countries where this language is the usual fallback for a device whose
  /// UI language is not itself a supported translation language.
  final Set<String> countries;

  const TranslationLanguage(
    this.code,
    this.tatoebaCode,
    this.label,
    this.countries,
  );

  /// 영어를 고르면 뜻은 영영 풀이로 채우고 예문 해석은 두지 않는다.
  bool get hasTranslations => this != english;

  bool matchesCode(dynamic value) =>
      value == code ||
      value == tatoebaCode ||
      (this == chinese && value == 'zho');

  static TranslationLanguage fromCode(dynamic code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => korean,
  );

  /// Device language first, then country; Korean when neither matches.
  static TranslationLanguage fromLocale(Locale locale) {
    final languageCode = locale.languageCode == 'in'
        ? 'id'
        : locale.languageCode;
    for (final language in values) {
      if (language.code == languageCode) return language;
    }
    final country = locale.countryCode?.toUpperCase();
    for (final language in values) {
      if (language.countries.contains(country)) return language;
    }
    return korean;
  }
}
