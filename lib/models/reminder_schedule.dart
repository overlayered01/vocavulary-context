import '../l10n/l10n.dart';

/// 선택한 요일마다 반복되는 알림 구간. 시작~끝 사이에 [intervalMinutes]마다
/// 단어 [wordCount]개를 담은 알림을 보낸다.
class ReminderSchedule {
  static const intervalOptions = [15, 30, 60, 90, 120, 180, 240, 360];
  static const maxWordCount = 10;

  /// [DateTime.monday](1) ~ [DateTime.sunday](7).
  static const allWeekdays = [1, 2, 3, 4, 5, 6, 7];

  final String id;
  final bool enabled;

  /// 자정 기준 분. 끝이 시작보다 이르면 자정을 넘는 구간이다.
  final int startMinutes;
  final int endMinutes;
  final int intervalMinutes;
  final int wordCount;

  /// 알림을 보낼 요일(1=월 … 7=일). 오름차순.
  final List<int> weekdays;

  const ReminderSchedule({
    required this.id,
    this.enabled = true,
    required this.startMinutes,
    required this.endMinutes,
    this.intervalMinutes = 60,
    this.wordCount = 3,
    this.weekdays = allWeekdays,
  });

  /// 하루 중 알림 시각들(자정 기준 분, 시작 시각 순).
  List<int> get slotMinutes {
    final span = (endMinutes - startMinutes) % (24 * 60);
    final step = intervalMinutes < 1 ? 1 : intervalMinutes;
    return [
      for (var offset = 0; offset <= span; offset += step)
        (startMinutes + offset) % (24 * 60),
    ];
  }

  ReminderSchedule copyWith({
    bool? enabled,
    int? startMinutes,
    int? endMinutes,
    int? intervalMinutes,
    int? wordCount,
    List<int>? weekdays,
  }) => ReminderSchedule(
    id: id,
    enabled: enabled ?? this.enabled,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    wordCount: wordCount ?? this.wordCount,
    weekdays: weekdays == null
        ? this.weekdays
        : ([...weekdays.toSet()]..sort()),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'enabled': enabled,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'intervalMinutes': intervalMinutes,
    'wordCount': wordCount,
    'weekdays': weekdays,
  };

  factory ReminderSchedule.fromMap(Map<String, dynamic> m) => ReminderSchedule(
    id: (m['id'] ?? '') as String,
    enabled: (m['enabled'] ?? true) as bool,
    startMinutes: (m['startMinutes'] ?? 9 * 60) as int,
    endMinutes: (m['endMinutes'] ?? 9 * 60) as int,
    intervalMinutes: (m['intervalMinutes'] ?? 60) as int,
    wordCount: ((m['wordCount'] ?? 3) as int).clamp(1, maxWordCount),
    weekdays: m['weekdays'] is List
        ? ({
            for (final d in m['weekdays'] as List)
              if (d is int && d >= 1 && d <= 7) d,
          }.toList()..sort())
        : allWeekdays,
  );

  /// 예: 매일, 평일, 주말, 월·수·금.
  String weekdaysLabel(AppLocalizations l10n) {
    final days = weekdays.toSet();
    if (days.length == 7) return l10n.reminderEveryDay;
    if (days.isEmpty) return l10n.reminderNoWeekdays;
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return l10n.reminderWeekdays;
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return l10n.reminderWeekends;
    }
    return [for (final d in weekdays) l10n.weekday(d)].join('·');
  }

  static String formatMinutes(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  static String intervalLabel(AppLocalizations l10n, int minutes) {
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return l10n.reminderIntervalMinutes(rest);
    if (rest == 0) return l10n.reminderIntervalHours(hours);
    return l10n.reminderIntervalHoursMinutes(hours, rest);
  }
}
