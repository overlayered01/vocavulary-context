import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/word.dart';

/// 매주 같은 시각에 반복되는 알림 한 건.
class PlannedReminder {
  /// 자정 기준 분.
  final int minutes;

  /// 보낼 요일(1=월 … 7=일). 7일 모두면 매일 반복 알림 하나로 예약한다.
  final List<int> weekdays;
  final List<Word> words;
  const PlannedReminder(this.minutes, this.weekdays, this.words);

  bool get daily => weekdays.length == 7;

  /// 이 알림이 차지하는 예약 개수.
  int get notificationCount => daily ? 1 : weekdays.length;

  String title(AppLocalizations l10n) => words.isEmpty
      ? l10n.notificationTitleDefault
      : l10n.notificationTitleWords(words.length);

  String body(AppLocalizations l10n) => words.isEmpty
      ? l10n.notificationBodyDefault
      : words.map((w) => '${w.term} — ${w.meaning}').join('\n');
}

/// iOS는 예약 알림을 64개까지만 유지하므로 여유를 두고 제한한다.
const maxPlannedReminders = 60;

/// 설정의 알림 구간과 단어 목록으로 한 주치 알림을 만든다.
///
/// 같은 요일·시각은 한 번만 보내고, 단어 수는 겹치는 구간 중 큰 값을 쓴다.
/// 학습 중인 단어를 복습 예정 순으로 먼저 쓰고, 알림마다 다른 단어가 오도록 돌아가며 고른다.
List<PlannedReminder> planReminders(AppSettings settings, List<Word> words) {
  if (!settings.reminderEnabled) return const [];
  final pool = rankReminderWords(words);
  var cursor = 0;
  var reserved = 0;
  final plan = <PlannedReminder>[];
  for (final group in _groupedSlots(settings)) {
    final reminder = PlannedReminder(group.minutes, group.weekdays, [
      for (var i = 0; i < group.wordCount && i < pool.length; i++)
        pool[(cursor++) % pool.length],
    ]);
    if (reserved + reminder.notificationCount > maxPlannedReminders) break;
    reserved += reminder.notificationCount;
    plan.add(reminder);
  }
  return plan;
}

/// 한 주 동안 울리는 알림 횟수(상한 적용 전).
int weeklyReminderCount(AppSettings settings) =>
    _wordCountsBySlot(settings).length;

/// 모두 예약하는 데 필요한 알림 개수. [maxPlannedReminders]를 넘으면 뒤쪽은 빠진다.
int requiredNotificationCount(AppSettings settings) => _groupedSlots(
  settings,
).fold(0, (sum, g) => sum + (g.weekdays.length == 7 ? 1 : g.weekdays.length));

/// (요일, 시각)별 단어 수.
Map<(int, int), int> _wordCountsBySlot(AppSettings settings) {
  final counts = <(int, int), int>{};
  for (final schedule in settings.reminderSchedules) {
    if (!schedule.enabled) continue;
    for (final minutes in schedule.slotMinutes) {
      // 자정을 넘긴 시각은 다음 날 알림이다.
      final nextDay = minutes < schedule.startMinutes;
      for (final day in schedule.weekdays) {
        final key = (nextDay ? day % 7 + 1 : day, minutes);
        final previous = counts[key] ?? 0;
        if (schedule.wordCount > previous) counts[key] = schedule.wordCount;
      }
    }
  }
  return counts;
}

/// 같은 시각·단어 수인 요일을 묶어 예약 개수를 줄인다. 시각 순으로 정렬한다.
List<({int minutes, int wordCount, List<int> weekdays})> _groupedSlots(
  AppSettings settings,
) {
  final groups = <(int, int), List<int>>{};
  _wordCountsBySlot(settings).forEach((key, count) {
    final (day, minutes) = key;
    groups.putIfAbsent((minutes, count), () => []).add(day);
  });
  final keys = groups.keys.toList()
    ..sort(
      (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
    );
  return [
    for (final key in keys)
      (minutes: key.$1, wordCount: key.$2, weekdays: groups[key]!..sort()),
  ];
}

/// 학습 중·새 단어를 복습 예정 시각 순으로, 완료한 단어는 뒤에 둔다.
List<Word> rankReminderWords(List<Word> words) {
  int byDue(Word a, Word b) {
    final ad = a.nextReviewAt, bd = b.nextReviewAt;
    if (ad == null && bd == null) return a.createdAt.compareTo(b.createdAt);
    if (ad == null) return -1;
    if (bd == null) return 1;
    return ad.compareTo(bd);
  }

  return [
    ...words.where((w) => w.status != LearnStatus.completed).toList()
      ..sort(byDue),
    ...words.where((w) => w.status == LearnStatus.completed).toList()
      ..sort(byDue),
  ];
}
