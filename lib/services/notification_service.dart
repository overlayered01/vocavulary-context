import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l10n.dart';
import 'reminder_planner.dart';

/// 로컬 알람(매일 반복되는 복습 알림)을 관리한다.
/// (기술스택비교: 고정 시간 알림은 flutter_local_notifications로 처리)
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'review_reminder';
  static const _reminderBaseId = 1001;
  // 이전 버전(최대 32개)과 현재 상한을 모두 지울 수 있는 범위.
  static const _scheduledReminderCount = 64;

  bool _initialized = false;

  /// 알림 탭 시 실행할 동작 (예: 복습 화면 열기). [init]에서 주입한다.
  VoidCallback? _onSelect;

  Future<void> init({VoidCallback? onSelect}) async {
    if (onSelect != null) _onSelect = onSelect;
    if (kIsWeb) return;
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) => _onSelect?.call(),
    );
    _initialized = true;
  }

  /// 앱이 알림 탭으로 (콜드 스타트) 실행됐는지 여부.
  Future<bool> launchedFromNotification() async {
    if (kIsWeb) return false;
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  /// 알림 권한 요청 (Android 13+/iOS).
  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// 알림을 매일(또는 선택한 요일마다) 같은 시각에 반복되도록 예약한다.
  /// 기존 예약은 지운다.
  Future<void> scheduleReminders(
    List<PlannedReminder> reminders,
    AppLocalizations l10n,
  ) async {
    if (kIsWeb) return;
    await init();
    await cancelReminder();
    await _syncLocalTimezone();

    var id = _reminderBaseId;
    try {
      for (final reminder in reminders) {
        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            l10n.notificationChannelName,
            channelDescription: l10n.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(reminder.body(l10n)),
          ),
          iOS: const DarwinNotificationDetails(),
        );
        final hour = reminder.minutes ~/ 60;
        final minute = reminder.minutes % 60;
        final targets = reminder.daily
            ? [(_nextInstanceOf(hour, minute), DateTimeComponents.time)]
            : [
                for (final day in reminder.weekdays)
                  (
                    _nextInstanceOf(hour, minute, weekday: day),
                    DateTimeComponents.dayOfWeekAndTime,
                  ),
              ];
        for (final (date, repeat) in targets) {
          await _plugin.zonedSchedule(
            id: id++,
            title: reminder.title(l10n),
            body: reminder.body(l10n),
            scheduledDate: date,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: repeat,
          );
        }
      }
    } catch (e) {
      debugPrint('알림 예약 실패: $e');
    }
  }

  Future<void> cancelReminder() async {
    if (kIsWeb) return;
    await init();
    for (var i = 0; i < _scheduledReminderCount; i++) {
      await _plugin.cancel(id: _reminderBaseId + i);
    }
  }

  /// tz.local을 기기 시간대로 맞춘다. timezone 패키지는 기본값이 UTC라서
  /// 이것이 없으면 '오전 9시' 알림이 UTC 9시(한국 오후 6시)에 울린다.
  /// 여행 등으로 시간대가 바뀔 수 있어 예약할 때마다 다시 읽는다.
  Future<void> _syncLocalTimezone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('기기 시간대 확인 실패: $e');
    }
  }

  /// 다음 [hour]:[minute] 시각. [weekday]가 있으면 그 요일 중 가장 가까운 날.
  tz.TZDateTime _nextInstanceOf(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (!scheduled.isAfter(now) ||
        (weekday != null && scheduled.weekday != weekday)) {
      scheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day + 1,
        hour,
        minute,
      );
    }
    return scheduled;
  }
}
