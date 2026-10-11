import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/local_repository.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';
import 'l10n/l10n.dart';
import 'models/app_settings.dart';
import 'models/reminder_schedule.dart';
import 'models/translation_language.dart';
import 'models/study_log.dart';
import 'models/word.dart';
import 'models/wordbook.dart';
import 'services/auth_service.dart';
import 'services/example_source_service.dart';
import 'services/dictionary_service.dart';
import 'services/local_dictionary.dart';
import 'services/offline_examples.dart';
import 'services/translation_packs.dart';
import 'services/mobile_ads_service.dart';
import 'services/notification_service.dart';
import 'services/reminder_planner.dart';
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
/// 위젯 밖(알림·서비스)에서 쓰는 현재 화면 언어의 문구.
final appL10nProvider = Provider<AppLocalizations>(
  (ref) => l10nFor(
    appLocaleFor(
      ref.watch(settingsProvider.select((s) => s.translationLanguageOverride)),
    ),
  ),
);
final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());
final mobileAdsServiceProvider = Provider<MobileAdsService>(
  (ref) => MobileAdsService(),
);

/// 앱에 내장한 언어판 사전. 한 번 읽은 내용은 앱이 끝날 때까지 유지한다.
final localDictionaryProvider = Provider<LocalDictionary>(
  (ref) => LocalDictionary(),
);
final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  final service = DictionaryService(
    l10n: ref.watch(appL10nProvider),
    local: ref.watch(localDictionaryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
final exampleSourceServiceProvider = Provider<ExampleSourceService>((ref) {
  final service = ExampleSourceService();
  ref.onDispose(service.dispose);
  return service;
});
final translationPacksProvider = Provider<TranslationPacks>((ref) {
  final packs = TranslationPacks();
  ref.onDispose(packs.dispose);
  return packs;
});
final offlineExamplesProvider = Provider<OfflineExamples>((ref) {
  final packs = ref.watch(translationPacksProvider);
  return OfflineExamples(
    // 예문 데이터를 받기로 했을 때만 해석을 쓴다.
    translations: (language) => ref.read(settingsProvider).exampleData == true
        ? packs.examples(language)
        : Future.value(const {}),
  );
});
final wordDraftServiceProvider = Provider<WordDraftService>(
  (ref) => WordDraftService(
    dictionary: ref.watch(dictionaryServiceProvider),
    examples: ref.watch(exampleSourceServiceProvider),
    offline: ref.watch(offlineExamplesProvider),
    translationLanguage: ref.watch(
      settingsProvider.select((s) => s.translationLanguage),
    ),
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

  /// 같은 id가 있으면 바꾸고, 없으면 목록 끝에 추가한다.
  Future<void> saveReminderSchedule(ReminderSchedule schedule) async {
    final list = [...state.reminderSchedules];
    final index = list.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      list[index] = schedule;
    } else {
      list.add(schedule);
    }
    list.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    state = state.copyWith(reminderSchedules: list);
    await _persist();
  }

  Future<void> removeReminderSchedule(String id) async {
    state = state.copyWith(
      reminderSchedules: [
        for (final s in state.reminderSchedules)
          if (s.id != id) s,
      ],
    );
    await _persist();
  }

  Future<void> setTtsLocale(String locale) async {
    // 목소리는 억양마다 다르므로 억양을 바꾸면 기본 목소리로 돌린다.
    state = state.copyWith(ttsLocale: locale, ttsVoice: '');
    await _persist();
  }

  Future<void> setTtsVoice(String voice) async {
    state = state.copyWith(ttsVoice: voice);
    await _persist();
  }

  Future<void> setTtsSpeed(String speed) async {
    state = state.copyWith(ttsSpeed: speed);
    await _persist();
  }

  Future<void> setRecordedPronunciation(bool value) async {
    state = state.copyWith(recordedPronunciation: value);
    await _persist();
  }

  Future<void> setSessionSize(int size) async {
    state = state.copyWith(sessionSize: size.clamp(5, 50));
    await _persist();
  }

  /// 프리셋 id 또는 'custom'.
  Future<void> setTheme(String id) async {
    state = state.copyWith(themeId: id);
    await _persist();
  }

  Future<void> setCustomTheme(int base, int point) async {
    state = state.copyWith(
      themeId: 'custom',
      customThemeBase: base,
      customThemePoint: point,
    );
    await _persist();
  }

  /// null이면 기기 언어·국가에 맞춰 자동으로 정한다.
  Future<void> setTranslationLanguage(TranslationLanguage? language) async {
    state = state.copyWith(
      translationLanguage: language,
      useDeviceTranslationLanguage: language == null,
    );
    await _persist();
  }

  Future<void> setExampleData(bool value) async {
    state = state.copyWith(exampleData: value);
    await _persist();
  }

  Future<void> setAutoInput({
    bool? meanings,
    bool? examples,
    bool? exampleTranslations,
    bool? expanded,
  }) async {
    state = state.copyWith(
      autoMeanings: meanings,
      autoExamples: examples,
      autoExampleTranslations: exampleTranslations,
      autoInputExpanded: expanded,
    );
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

/// 예문 없는 카드에 내장 예문 색인에서 다시 찾은 예문 (단어 id → 최대 3개).
/// 기기 안에서 찾으므로 빠르고, 단어나 예문 해석 데이터가 바뀌면 다시 찾는다.
final exampleSuggestionsProvider =
    FutureProvider.autoDispose<Map<String, List<Example>>>((ref) async {
      final packs = ref.watch(translationPacksProvider);
      void refresh() => ref.invalidateSelf();
      packs.status.addListener(refresh);
      ref.onDispose(() => packs.status.removeListener(refresh));
      final words = await ref.watch(allWordsProvider.future);
      final offline = ref.watch(offlineExamplesProvider);
      final language = ref.watch(
        settingsProvider.select((s) => s.translationLanguage),
      );
      final found = <String, List<Example>>{};
      for (final word in words) {
        if (word.examples.isNotEmpty) continue;
        final examples = await offline.find(
          word.term,
          word.partOfSpeech,
          translationLanguage: language,
        );
        if (examples.isNotEmpty) found[word.id] = examples.take(3).toList();
      }
      return found;
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

/// 최신 설정과 단어로 복습 알림을 다시 예약한다. 꺼져 있으면 예약을 지운다.
///
/// [ref]는 첫 await 전에만 읽으므로, 호출한 위젯이 곧 사라져도 안전하다.
Future<void> rescheduleReminders(WidgetRef ref) async {
  try {
    final settings = ref.read(settingsProvider);
    final notifications = ref.read(notificationServiceProvider);
    if (!settings.reminderEnabled) {
      await notifications.cancelReminder();
      return;
    }
    final repository = ref.read(repositoryProvider);
    final l10n = ref.read(appL10nProvider);
    final words = await repository.getAllWords();
    await notifications.scheduleReminders(planReminders(settings, words), l10n);
  } catch (e) {
    debugPrint('알림 다시 예약 실패: $e');
  }
}
