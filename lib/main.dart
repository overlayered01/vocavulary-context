import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/local_repository.dart';
import 'models/app_settings.dart';
import 'providers.dart';
import 'screens/review_screen.dart';
import 'services/notification_service.dart';
import 'supabase_config.dart';

/// 알림을 탭하면 바로 예문 복습 화면으로 진입한다.
void _openReview() {
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const ReviewScreen()),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화 시도. URL/anon key 미설정이면 로컬 모드로 동작.
  bool cloudAvailable = false;
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // Supabase 대시보드의 anon/publishable key. (구버전 명칭: anon key)
        publishableKey: SupabaseConfig.anonKey,
      );
      cloudAvailable = true;
      debugPrint('Supabase 초기화 성공 — 클라우드 동기화 가능');
    } catch (e) {
      debugPrint('Supabase 초기화 실패 — 로컬 모드로 실행합니다. ($e)');
    }
  } else {
    debugPrint('Supabase 미설정 — 로컬 모드로 실행합니다.');
  }

  final prefs = await SharedPreferences.getInstance();
  final settings = await AppSettings.load(prefs);

  final localRepo = LocalRepository();
  await localRepo.init();

  // 알림 서비스 초기화 + 설정에 따라 예약.
  final notifications = NotificationService();
  await notifications.init(onSelect: _openReview);
  if (settings.reminderEnabled) {
    // 기본값이 '켜짐'이므로 첫 실행 시 한 번은 여기서 권한을 요청한다.
    // (이후에는 설정 화면의 토글에서만 요청)
    const permAskedKey = 'notif_permission_requested';
    if (!(prefs.getBool(permAskedKey) ?? false)) {
      await notifications.requestPermissions();
      await prefs.setBool(permAskedKey, true);
    }
    await notifications.scheduleDailyReminder(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
      quiet: settings.quietWindow,
    );
  }
  final launchedFromNotification = await notifications
      .launchedFromNotification();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        cloudAvailableProvider.overrideWithValue(cloudAvailable),
        localRepositoryProvider.overrideWithValue(localRepo),
        initialSettingsProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const VocabularyApp(),
    ),
  );

  // 알림 탭으로 앱이 켜진 경우(콜드 스타트) 첫 프레임 후 복습 화면을 연다.
  if (launchedFromNotification) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _openReview());
  }
}
