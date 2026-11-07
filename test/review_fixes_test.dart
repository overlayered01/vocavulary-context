import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/data/srs.dart';
import 'package:vocabulary/l10n/l10n.dart';
import 'package:vocabulary/models/app_settings.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/review_screen.dart';
import 'package:vocabulary/screens/wordbook_detail_screen.dart';
import 'package:vocabulary/theme.dart';
import 'package:vocabulary/widgets/panel.dart';

void main() {
  final date = DateTime(2026, 11, 7);
  late SharedPreferences prefs;
  late LocalRepository repo;
  late Wordbook book;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'seeded_v1': true});
    prefs = await SharedPreferences.getInstance();
    repo = LocalRepository();
    await repo.init();
    book = await repo.createWordbook(
      Wordbook(
        id: 'book',
        ownerId: 'local',
        title: 'Default',
        createdAt: date,
        updatedAt: date,
      ),
    );
  });

  Future<Word> addWord(String term, {bool discarded = false}) async {
    final word = await repo.upsertWord(
      Word(
        id: '',
        wordbookId: book.id,
        term: term,
        partOfSpeech: '동사',
        meanings: const ['뜻'],
        examples: [Example(sentence: 'They had to $term the car.')],
        createdAt: date,
        updatedAt: date,
      ),
    );
    if (!discarded) return word;
    return repo.upsertWord(Srs.discard(word, date));
  }

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          sharedPrefsProvider.overrideWithValue(prefs),
          appL10nProvider.overrideWithValue(
            lookupAppLocalizations(const Locale('ko')),
          ),
          initialSettingsProvider.overrideWithValue(
            await AppSettings.load(prefs),
          ),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inside(String key, Type type) => find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(type),
  );

  testWidgets('복습에 섞여 나온 버린 카드는 남기기를 고를 때까지 버린 상태로 남는다', (tester) async {
    await addWord('abandon', discarded: true);
    await pumpScreen(tester, const ReviewScreen(mode: ReviewMode.meaning));

    // 모른다 → 답이 보이지만 아직 남길지 버릴지 고르지 않았다.
    await tester.tap(inside('input-actions', PanelOutlineButton).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('decide')), findsOneWidget);
    var saved = (await repo.getWords(book.id)).single;
    expect(saved.status, LearnStatus.completed);
    expect(saved.timesWrong, 1, reason: '채점 기록은 남는다');

    // 남기기를 고르면 그때 덱으로 돌아온다.
    await tester.tap(inside('decide', PanelOutlineButton));
    await tester.pumpAndSettle();
    saved = (await repo.getWords(book.id)).single;
    expect(saved.status, LearnStatus.learning);
  });

  testWidgets('버린 카드 화면에서 되살린 카드는 돌아오면 목록에 다시 보인다', (tester) async {
    final word = await addWord('abandon');
    await pumpScreen(tester, WordbookDetailScreen(book: book));

    await tester.timedDrag(
      find.text('abandon'),
      const Offset(300, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    expect(find.text('abandon'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('open-discarded')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('restore-${word.id}')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(WordbookDetailScreen), findsOneWidget);
    expect(find.text('abandon'), findsOneWidget);
    final left = tester.widget<Text>(
      find.byKey(const ValueKey('wordbook-left')),
    );
    expect(left.textSpan!.toPlainText(), startsWith('1 '));
  });
}
