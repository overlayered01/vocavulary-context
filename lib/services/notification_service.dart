import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 로컬 알람(정시 반복 복습 알림)을 관리한다.
/// (기술스택비교: 고정 시간 알림은 flutter_local_notifications로 처리)
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'review_reminder';
  static const _reminderBaseId = 1001;
  static const _scheduledReminderCount = 32;

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

  /// 지정 시각과 일 단위 간격으로 복습 알림을 예약한다.
  ///
  /// [quiet]가 주어지고 알림 시각이 방해금지 구간 안이면
  /// 구간이 끝나는 시각으로 미뤄서 예약한다.
  Future<void> scheduleReminder({
    required int hour,
    required int minute,
    required int intervalDays,
    ({int startMinutes, int endMinutes})? quiet,
    String title = '복습 시간이에요',
    String body = '오늘 외울 단어가 기다리고 있어요. 탭하면 바로 학습!',
  }) async {
    if (kIsWeb) return;
    await init();
    await cancelReminder();

    if (quiet != null && _inQuietWindow(hour * 60 + minute, quiet)) {
      hour = quiet.endMinutes ~/ 60;
      minute = quiet.endMinutes % 60;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        '복습 알림',
        channelDescription: '주기적인 단어 복습 리마인더',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      if (intervalDays <= 1) {
        await _plugin.zonedSchedule(
          id: _reminderBaseId,
          title: title,
          body: body,
          scheduledDate: _nextInstanceOf(hour, minute),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        return;
      }

      final first = _nextInstanceOf(hour, minute);
      for (var i = 0; i < _scheduledReminderCount; i++) {
        final scheduledDate = tz.TZDateTime(
          tz.local,
          first.year,
          first.month,
          first.day + i * intervalDays,
          hour,
          minute,
        );
        await _plugin.zonedSchedule(
          id: _reminderBaseId + i,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('알림 예약 실패: $e');
    }
  }

  Future<void> cancelReminder() async {
    if (kIsWeb) return;
    for (var i = 0; i < _scheduledReminderCount; i++) {
      await _plugin.cancel(id: _reminderBaseId + i);
    }
  }

  /// [minutes](자정 기준 분)가 방해금지 구간 안인지. 자정을 넘는 구간도 지원.
  static bool _inQuietWindow(
    int minutes,
    ({int startMinutes, int endMinutes}) quiet,
  ) {
    final (:startMinutes, :endMinutes) = quiet;
    if (startMinutes == endMinutes) return false; // 길이 0 구간
    if (startMinutes < endMinutes) {
      return minutes >= startMinutes && minutes < endMinutes;
    }
    return minutes >= startMinutes || minutes < endMinutes;
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
