import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/local_repository.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';
import 'models/app_settings.dart';
import 'models/study_log.dart';
import 'models/word.dart';
import 'models/wordbook.dart';
import 'services/auth_service.dart';
import 'services/example_source_service.dart';
import 'services/dictionary_service.dart';
import 'services/notification_service.dart';
import 'services/tts_service.dart';
import 'services/word_draft_service.dart';

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
final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  final service = DictionaryService();
  ref.onDispose(service.dispose);
  return service;
});
final exampleSourceServiceProvider = Provider<ExampleSourceService>((ref) {
  final service = ExampleSourceService();
  ref.onDispose(service.dispose);
  return service;
});
final wordDraftServiceProvider = Provider<WordDraftService>(
  (ref) => WordDraftService(
    dictionary: ref.watch(dictionaryServiceProvider),
    examples: ref.watch(exampleSourceServiceProvider),
  ),
);
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

  Future<void> setReminderIntervalDays(int days) async {
    state = state.copyWith(reminderIntervalDays: days);
    await _persist();
  }

  Future<void> setQuietEnabled(bool v) async {
    state = state.copyWith(quietEnabled: v);
    await _persist();
  }

  Future<void> setQuietStart(int hour, int minute) async {
    state = state.copyWith(quietStartHour: hour, quietStartMinute: minute);
    await _persist();
  }

  Future<void> setQuietEnd(int hour, int minute) async {
    state = state.copyWith(quietEndHour: hour, quietEndMinute: minute);
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

/// 다른 사용자의 공개 단어장 목록 (탐색 탭). 클라우드 로그인 상태에서만 조회.
final publicWordbooksProvider = FutureProvider.autoDispose<List<Wordbook>>((
  ref,
) {
  final repo = ref.watch(repositoryProvider);
  if (repo is! SupabaseRepository) return Future.value(const <Wordbook>[]);
  return repo.getPublicWordbooks();
});

/// 오늘(자정 이후) 학습 기록. 홈의 '오늘 학습' 통계에 사용.
final todayStudyLogsProvider = FutureProvider.autoDispose<List<StudyLog>>((
  ref,
) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(repositoryProvider).getStudyLogsSince(startOfDay);
});

/// 데이터 변경 후 화면 갱신용 헬퍼.
void invalidateData(WidgetRef ref) {
  ref.invalidate(wordbooksProvider);
  ref.invalidate(allWordsProvider);
  ref.invalidate(todayStudyLogsProvider);
}
