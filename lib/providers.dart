import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/local_repository.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';
import 'models/app_settings.dart';
import 'models/word.dart';
import 'models/wordbook.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/tts_service.dart';

/// 부팅 시 override로 주입되는 프로바이더들.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main에서 override'),
);
final cloudAvailableProvider = Provider<bool>((ref) => false);
final localRepositoryProvider = Provider<LocalRepository>(
  (ref) => throw UnimplementedError('main에서 override'),
);
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

// ---- 서비스 ----
final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// 로그인 상태 스트림 (Supabase 미설정 시 항상 null).
final authUserProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(cloudAvailableProvider)) {
    return Stream<User?>.value(null);
  }
  return ref.watch(authServiceProvider).authStateChanges();
});

/// 현재 활성 저장소. 로그인 시 Supabase, 아니면 로컬.
final repositoryProvider = Provider<VocabRepository>((ref) {
  final cloudAvailable = ref.watch(cloudAvailableProvider);
  final user = ref.watch(authUserProvider).asData?.value;
  if (cloudAvailable && user != null) {
    final repo = SupabaseRepository();
    repo.init();
    return repo;
  }
  return ref.watch(localRepositoryProvider);
});

// ---- 설정 ----
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> _persist() async {
    await state.save(ref.read(sharedPrefsProvider));
  }

  Future<void> setMixRatio(int v) async {
    state = state.copyWith(reviewMixRatio: v);
    await _persist();
  }

  Future<void> setReminderEnabled(bool v) async {
    state = state.copyWith(reminderEnabled: v);
    await _persist();
  }

  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _persist();
  }

  Future<void> setTtsLocale(String locale) async {
    state = state.copyWith(ttsLocale: locale);
    await _persist();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ---- 네비게이션 ----

/// 하단 탭 인덱스 (0=홈, 1=단어장, 2=설정). 홈의 바로가기 등에서 탭 전환에 사용.
class HomeTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, int>(
  HomeTabNotifier.new,
);

// ---- 데이터 ----
final wordbooksProvider = FutureProvider.autoDispose<List<Wordbook>>((ref) {
  return ref.watch(repositoryProvider).getWordbooks();
});

final wordsProvider = FutureProvider.autoDispose.family<List<Word>, String>((
  ref,
  bookId,
) {
  return ref.watch(repositoryProvider).getWords(bookId);
});

final allWordsProvider = FutureProvider.autoDispose<List<Word>>((ref) {
  return ref.watch(repositoryProvider).getAllWords();
});

/// 데이터 변경 후 화면 갱신용 헬퍼.
void invalidateData(WidgetRef ref) {
  ref.invalidate(wordbooksProvider);
  ref.invalidate(allWordsProvider);
}
