import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/l10n/l10n.dart';
import 'package:vocabulary/models/app_settings.dart';
import 'package:vocabulary/models/translation_language.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/home_screen.dart';
import 'package:vocabulary/screens/settings_screen.dart';
import 'package:vocabulary/screens/about_screen.dart';
import 'package:vocabulary/screens/word_add_screen.dart';
import 'package:vocabulary/screens/word_detail_screen.dart';
import 'package:vocabulary/screens/word_edit_screen.dart';
import 'package:vocabulary/screens/wordbook_detail_screen.dart';
import 'package:vocabulary/screens/wordbooks_screen.dart';
import 'package:vocabulary/theme.dart';

final _hangul = RegExp(r'[가-힣]');

/// 화면에 보이는 모든 글자 중 한글이 남은 것.
List<String> visibleHangul(WidgetTester tester) => [
  for (final widget in tester.widgetList<RichText>(find.byType(RichText)))
    if (_hangul.hasMatch(widget.text.toPlainText())) widget.text.toPlainText(),
];

void main() {
  late LocalRepository repo;
  late SharedPreferences prefs;
  late Wordbook book;
  late Word word;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'seeded_v1': true});
    prefs = await SharedPreferences.getInstance();
    repo = LocalRepository();
    await repo.init();
    final date = DateTime(2026);
    book = await repo.createWordbook(
      Wordbook(
        id: '',
        ownerId: '',
        title: 'My book',
        createdAt: date,
        updatedAt: date,
      ),
    );
    word = await repo.upsertWord(
      Word(
        id: '',
        wordbookId: book.id,
        term: 'run',
        translationLanguage: 'en',
        meanings: const ['to move fast'],
        partOfSpeech: '동사',
        examples: const [Example(sentence: 'I run.')],
        createdAt: date,
        updatedAt: date,
      ),
    );
  });

  Future<void> pumpIn(WidgetTester tester, Locale locale, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(360, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          localRepositoryProvider.overrideWithValue(repo),
          initialSettingsProvider.overrideWithValue(const AppSettings()),
          appL10nProvider.overrideWithValue(lookupAppLocalizations(locale)),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final screens = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'wordbooks': () => const WordbooksScreen(),
    'wordbook detail': () => WordbookDetailScreen(book: book),
    'word detail': () => WordDetailScreen(word: word),
    'word add': () => WordAddScreen(wordbookId: book.id),
    'discarded': () => DiscardedScreen(book: book),
    'about': () => const AboutScreen(),
    'word edit': () => WordEditScreen(wordbookId: book.id, existing: word),
    'settings': () => const SettingsScreen(),
  };
  // 화면이 넘치면 테스트 프레임워크가 오류로 잡는다.
  for (final locale in AppLocalizations.supportedLocales) {
    for (final entry in screens.entries) {
      testWidgets('${locale.languageCode} 화면이 넘치지 않고 번역되어 있다: ${entry.key}', (
        tester,
      ) async {
        await pumpIn(tester, locale, entry.value());
        if (locale.languageCode != 'ko') {
          expect(visibleHangul(tester), isEmpty);
        }
      });
    }
  }

  testWidgets('번역 언어를 고르면 앱 화면 언어가 따라 바뀐다', (tester) async {
    expect(appLocaleFor(null), isNull);
    expect(appLocaleFor(TranslationLanguage.japanese), const Locale('ja'));
    // 화면 번역이 없는 언어는 영어 문구를 쓴다.
    expect(l10nFor(const Locale('ru')).commonSave, 'Save');
    expect(l10nFor(const Locale('ko')).commonSave, '저장');
  });
}
