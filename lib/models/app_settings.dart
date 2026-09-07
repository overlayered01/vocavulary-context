import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자 설정. 복습 섞기 비율·알람·TTS 옵션을 보관한다.
class AppSettings {
  /// 이미 외운(완료) 단어를 복습에 섞는 비율 0~100.
  final int reviewMixRatio;

  /// 복습 알림 사용 여부.
  final bool reminderEnabled;

  /// 알림 시각(시, 분). 기본 오전 9시.
  final int reminderHour;
  final int reminderMinute;

  /// 복습 알림 반복 간격(일). 1이면 매일 알림.
  final int reminderIntervalDays;

  /// 방해금지(조용한 시간) 사용 여부. 이 시간대에는 복습 알림을 미룬다.
  final bool quietEnabled;

  /// 방해금지 시작/끝 시각. 자정을 넘는 구간(예: 22:00~07:00)도 허용.
  final int quietStartHour;
  final int quietStartMinute;
  final int quietEndHour;
  final int quietEndMinute;

  /// TTS 언어 (미국식/영국식).
  final String ttsLocale; // 'en-US' | 'en-GB'

  /// 한 복습 세션 문항 수.
  final int sessionSize;

  const AppSettings({
    this.reviewMixRatio = 20,
    this.reminderEnabled = true,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.reminderIntervalDays = 1,
    this.quietEnabled = false,
    this.quietStartHour = 22,
    this.quietStartMinute = 0,
    this.quietEndHour = 7,
    this.quietEndMinute = 0,
    this.ttsLocale = 'en-US',
    this.sessionSize = 15,
  });

  /// 방해금지 구간(자정 기준 분 단위). 꺼져 있으면 null.
  ({int startMinutes, int endMinutes})? get quietWindow => quietEnabled
      ? (
          startMinutes: quietStartHour * 60 + quietStartMinute,
          endMinutes: quietEndHour * 60 + quietEndMinute,
        )
      : null;

  AppSettings copyWith({
    int? reviewMixRatio,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? reminderIntervalDays,
    bool? quietEnabled,
    int? quietStartHour,
    int? quietStartMinute,
    int? quietEndHour,
    int? quietEndMinute,
    String? ttsLocale,
    int? sessionSize,
  }) {
    return AppSettings(
      reviewMixRatio: reviewMixRatio ?? this.reviewMixRatio,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderIntervalDays: reminderIntervalDays ?? this.reminderIntervalDays,
      quietEnabled: quietEnabled ?? this.quietEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietStartMinute: quietStartMinute ?? this.quietStartMinute,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      quietEndMinute: quietEndMinute ?? this.quietEndMinute,
      ttsLocale: ttsLocale ?? this.ttsLocale,
      sessionSize: sessionSize ?? this.sessionSize,
    );
  }

  Map<String, dynamic> toMap() => {
    'reviewMixRatio': reviewMixRatio,
    'reminderEnabled': reminderEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'reminderIntervalDays': reminderIntervalDays,
    'quietEnabled': quietEnabled,
    'quietStartHour': quietStartHour,
    'quietStartMinute': quietStartMinute,
    'quietEndHour': quietEndHour,
    'quietEndMinute': quietEndMinute,
    'ttsLocale': ttsLocale,
    'sessionSize': sessionSize,
  };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
    reviewMixRatio: (m['reviewMixRatio'] ?? 20) as int,
    reminderEnabled: (m['reminderEnabled'] ?? true) as bool,
    reminderHour: (m['reminderHour'] ?? 9) as int,
    reminderMinute: (m['reminderMinute'] ?? 0) as int,
    reminderIntervalDays: (m['reminderIntervalDays'] ?? 1) as int,
    quietEnabled: (m['quietEnabled'] ?? false) as bool,
    quietStartHour: (m['quietStartHour'] ?? 22) as int,
    quietStartMinute: (m['quietStartMinute'] ?? 0) as int,
    quietEndHour: (m['quietEndHour'] ?? 7) as int,
    quietEndMinute: (m['quietEndMinute'] ?? 0) as int,
    ttsLocale: (m['ttsLocale'] ?? 'en-US') as String,
    sessionSize: (m['sessionSize'] ?? 15) as int,
  );

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
