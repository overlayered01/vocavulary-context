import 'dart:convert';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:shared_preferences/shared_preferences.dart';
import 'reminder_schedule.dart';
import 'translation_language.dart';

/// 사용자 설정. 복습 섞기 비율·알람·TTS·테마 옵션을 보관한다.
class AppSettings {
  /// 이미 외운(완료) 단어를 복습에 섞는 비율 0~100.
  final int reviewMixRatio;

  /// 복습 알림 사용 여부.
  final bool reminderEnabled;

  /// 매일 반복되는 알림 구간 목록.
  final List<ReminderSchedule> reminderSchedules;

  /// TTS 언어 (미국식/영국식).
  final String ttsLocale; // 'en-US' | 'en-GB'

  /// 한 복습 세션 문항 수.
  final int sessionSize;

  /// 사용자가 고른 뜻·예문 번역 언어. null이면 기기 언어·국가로 정한다.
  final TranslationLanguage? translationLanguageOverride;

  /// 단어 추가 화면의 자동 뜻·예문 입력과 옵션 패널 펼침 상태.
  final bool autoMeanings;
  final bool autoExamples;

  /// 자동 예문에 선택 언어의 해석을 함께 넣을지.
  final bool autoExampleTranslations;
  final bool autoInputExpanded;

  /// 테마 프리셋 id ('slate' 등). 'custom'이면 [customThemeBase]·[customThemePoint]를 쓴다.
  final String themeId;
  final int customThemeBase;
  final int customThemePoint;

  /// 기기 TTS 목소리 이름. 빈 문자열이면 억양에 맞는 기본 목소리.
  final String ttsVoice;

  /// 읽기 속도 'slow' | 'normal' | 'fast'.
  final String ttsSpeed;

  /// 단어는 Wiktionary 사람 녹음을 먼저 재생한다.
  final bool recordedPronunciation;

  /// 예문 해석 데이터를 내려받을지. null이면 아직 묻지 않았다.
  final bool? exampleData;

  const AppSettings({
    this.reviewMixRatio = 20,
    this.reminderEnabled = true,
    this.reminderSchedules = defaultReminderSchedules,
    this.ttsLocale = 'en-US',
    this.sessionSize = 15,
    TranslationLanguage? translationLanguage,
    this.autoMeanings = true,
    this.autoExamples = true,
    this.autoExampleTranslations = true,
    this.autoInputExpanded = false,
    this.themeId = 'slate',
    this.customThemeBase = 0xFF2F5D50,
    this.customThemePoint = 0xFFF6C9A0,
    this.ttsVoice = '',
    this.ttsSpeed = 'normal',
    this.recordedPronunciation = true,
    this.exampleData,
  }) : translationLanguageOverride = translationLanguage;

  static const defaultReminderSchedules = [
    ReminderSchedule(
      id: 'default',
      startMinutes: 9 * 60,
      endMinutes: 21 * 60,
      intervalMinutes: 180,
      wordCount: 3,
    ),
  ];

  TranslationLanguage get translationLanguage =>
      translationLanguageOverride ?? deviceTranslationLanguage;

  static TranslationLanguage get deviceTranslationLanguage =>
      TranslationLanguage.fromLocale(
        WidgetsBinding.instance.platformDispatcher.locale,
      );

  AppSettings copyWith({
    int? reviewMixRatio,
    bool? reminderEnabled,
    List<ReminderSchedule>? reminderSchedules,
    String? ttsLocale,
    int? sessionSize,
    TranslationLanguage? translationLanguage,
    bool useDeviceTranslationLanguage = false,
    bool? autoMeanings,
    bool? autoExamples,
    bool? autoExampleTranslations,
    bool? autoInputExpanded,
    String? themeId,
    int? customThemeBase,
    int? customThemePoint,
    String? ttsVoice,
    String? ttsSpeed,
    bool? recordedPronunciation,
    bool? exampleData,
  }) {
    return AppSettings(
      reviewMixRatio: reviewMixRatio ?? this.reviewMixRatio,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderSchedules: reminderSchedules ?? this.reminderSchedules,
      ttsLocale: ttsLocale ?? this.ttsLocale,
      sessionSize: sessionSize ?? this.sessionSize,
      translationLanguage: useDeviceTranslationLanguage
          ? null
          : translationLanguage ?? translationLanguageOverride,
      autoMeanings: autoMeanings ?? this.autoMeanings,
      autoExamples: autoExamples ?? this.autoExamples,
      autoExampleTranslations:
          autoExampleTranslations ?? this.autoExampleTranslations,
      autoInputExpanded: autoInputExpanded ?? this.autoInputExpanded,
      themeId: themeId ?? this.themeId,
      customThemeBase: customThemeBase ?? this.customThemeBase,
      customThemePoint: customThemePoint ?? this.customThemePoint,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      recordedPronunciation:
          recordedPronunciation ?? this.recordedPronunciation,
      exampleData: exampleData ?? this.exampleData,
    );
  }

  Map<String, dynamic> toMap() => {
    'reviewMixRatio': reviewMixRatio,
    'reminderEnabled': reminderEnabled,
    'reminderSchedules': [for (final s in reminderSchedules) s.toMap()],
    'ttsLocale': ttsLocale,
    'sessionSize': sessionSize,
    if (translationLanguageOverride != null)
      'translationLanguage': translationLanguageOverride!.code,
    'autoMeanings': autoMeanings,
    'autoExamples': autoExamples,
    'autoExampleTranslations': autoExampleTranslations,
    'autoInputExpanded': autoInputExpanded,
    'themeId': themeId,
    'customThemeBase': customThemeBase,
    'customThemePoint': customThemePoint,
    'ttsVoice': ttsVoice,
    'ttsSpeed': ttsSpeed,
    'recordedPronunciation': recordedPronunciation,
    if (exampleData != null) 'exampleData': exampleData,
  };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
    reviewMixRatio: (m['reviewMixRatio'] ?? 20) as int,
    reminderEnabled: (m['reminderEnabled'] ?? true) as bool,
    reminderSchedules: _schedulesFromMap(m),
    ttsLocale: (m['ttsLocale'] ?? 'en-US') as String,
    sessionSize: (m['sessionSize'] ?? 15) as int,
    translationLanguage: m['translationLanguage'] == null
        ? null
        : TranslationLanguage.fromCode(m['translationLanguage']),
    autoMeanings: (m['autoMeanings'] ?? true) as bool,
    autoExamples: (m['autoExamples'] ?? true) as bool,
    autoExampleTranslations: (m['autoExampleTranslations'] ?? true) as bool,
    autoInputExpanded: (m['autoInputExpanded'] ?? false) as bool,
    themeId: (m['themeId'] ?? 'slate') as String,
    customThemeBase: (m['customThemeBase'] ?? 0xFF2F5D50) as int,
    customThemePoint: (m['customThemePoint'] ?? 0xFFF6C9A0) as int,
    ttsVoice: (m['ttsVoice'] ?? '') as String,
    ttsSpeed: (m['ttsSpeed'] ?? 'normal') as String,
    recordedPronunciation: (m['recordedPronunciation'] ?? true) as bool,
    exampleData: m['exampleData'] as bool?,
  );

  /// 이전 버전의 단일 알림 시각은 같은 시각 한 번짜리 구간으로 옮긴다.
  static List<ReminderSchedule> _schedulesFromMap(Map<String, dynamic> m) {
    final raw = m['reminderSchedules'];
    if (raw is List) {
      return [
        for (final item in raw)
          ReminderSchedule.fromMap(Map<String, dynamic>.from(item as Map)),
      ];
    }
    if (m['reminderHour'] == null) return defaultReminderSchedules;
    final minutes =
        (m['reminderHour'] as int) * 60 + ((m['reminderMinute'] ?? 0) as int);
    return [
      ReminderSchedule(
        id: 'legacy',
        startMinutes: minutes,
        endMinutes: minutes,
      ),
    ];
  }

  static const _key = 'app_settings';

  static Future<AppSettings> load(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    return AppSettings.fromMap(Map<String, dynamic>.from(jsonDecode(raw)));
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setString(_key, jsonEncode(toMap()));
  }
}
