import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/data/srs.dart';
import 'package:vocabulary/l10n/l10n.dart';
import 'package:vocabulary/models/app_settings.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/word_add_screen.dart';
import 'package:vocabulary/screens/word_detail_screen.dart';
import 'package:vocabulary/screens/wordbook_detail_screen.dart';
import 'package:vocabulary/services/dictionary_service.dart';
import 'package:vocabulary/services/example_source_service.dart';
import 'package:vocabulary/services/offline_examples.dart';
import 'package:vocabulary/models/translation_language.dart';
import 'package:vocabulary/services/word_draft_service.dart';
import 'package:vocabulary/theme.dart';

http.Response dictionaryResponse() => http.Response(
  jsonEncode({
    'entries': [
      {
        'language': {'code': 'en'},
        'partOfSpeech': 'verb',
        'pronunciations': [
          {'type': 'ipa', 'text': '/rʌn/'},
        ],
        'senses': [
          {
            'definition': 'Move quickly on foot.',
            'translations': [
              {
                'language': {'code': 'ko'},
                'word': '달리다',
              },
            ],
            'examples': ['We run together every morning.', 'run fast'],
          },
          {
            'definition': 'An outdated usage.',
            'tags': ['archaic'],
          },
          {
            'definition': 'Manage a company.',
            'translations': [
              {
                'language': {'code': 'ko'},
                'word': '운영하다',
              },
            ],
          },
          {'definition': 'Function or operate.'},
        ],
      },
      {
        'language': {'code': 'en'},
        'partOfSpeech': 'noun',
        'senses': [
          {
            'definition': 'An act of running.',
            'translations': [
              {
                'language': {'code': 'ko'},
                'word': '달리기',
              },
            ],
          },
        ],
      },
    ],
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response examplesResponse() => http.Response(
  jsonEncode({
    'data': [
      {
        'id': 1,
        'text': 'I run every day.',
        'translations': [
          {'lang': 'kor', 'text': '나는 매일 달린다.'},
        ],
      },
      {
        'id': 2,
        'text': 'That was a good run.',
        'translations': [
          {'lang': 'kor', 'text': '좋은 달리기였다.'},
        ],
      },
    ],
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

final noOfflineExamples = OfflineExamples(
  loadAsset: (_) async => throw Exception('no bundled examples'),
);

void main() {
  late DictionaryService dictionary;
  late ExampleSourceService examples;
  late LocalRepository repo;
  late SharedPreferences prefs;
  late Wordbook book;
  final date = DateTime(2026, 9, 13);

  setUp(() async {
    dictionary = DictionaryService(
      client: MockClient((_) async => dictionaryResponse()),
    );
    examples = ExampleSourceService(
      client: MockClient((_) async => examplesResponse()),
    );
    SharedPreferences.setMockInitialValues({'seeded_v1': true});
    prefs = await SharedPreferences.getInstance();
    repo = LocalRepository();
    await repo.init();
    book = await repo.createWordbook(
      Wordbook(
        id: 'book',
        ownerId: 'local',
        title: '내 단어장',
        createdAt: date,
        updatedAt: date,
      ),
    );
  });
  tearDown(() {
    dictionary.dispose();
    examples.dispose();
  });

  WordDraftService service() =>
      WordDraftService(dictionary: dictionary, examples: examples);

  test('사전 뜻을 품사별 카드로 묶고 번역 있는 뜻만 쓴다', () async {
    final lookup = await service().lookup('run');
    expect(lookup.phonetic, '/rʌn/');
    expect(lookup.groups.map((g) => g.partOfSpeech), ['동사', '명사']);
    final verb = lookup.groups.first;
    expect(verb.meanings, ['달리다', '운영하다']);
    expect(verb.englishOnly, isFalse);
    // 짧은 구절은 예문 후보에서 뺀다.
    expect(verb.examples.map((e) => e.sentence), [
      'We run together every morning.',
    ]);
    expect(lookup.groups.last.meanings, ['달리기']);
  });

  test('Tatoeba 예문은 고른 품사로 쓰인 문장만 남긴다', () async {
    final verbs = await service().tatoebaExamples('run', '동사');
    expect(verbs.map((e) => e.sentence), ['I run every day.']);
    final nouns = await service().tatoebaExamples('run', '명사');
    expect(nouns.map((e) => e.sentence), ['That was a good run.']);
    expect(
      WordDraftService.matchesPartOfSpeech('He will run.', 'run', '명사'),
      isFalse,
    );
    expect(
      WordDraftService.matchesPartOfSpeech('Runs are fun.', 'run', '형용사'),
      isTrue,
    );
  });

  test('내장 예문은 품사 색인으로 고르고 해석이 있는 문장을 앞에 둔다', () async {
    final assets = {
      'assets/examples/en.json': jsonEncode({
        'sentences': {
          '1': 'I run every day.',
          '2': 'We run to school.',
          '3': 'They run fast.',
          '4': 'That was a good run.',
        },
        'index': {
          'run|verb': [1, 2, 3],
          'run|noun': [4],
        },
      }),
    };
    final offline = OfflineExamples(
      loadAsset: (path) async => assets[path]!,
      translations: (language) async => language == TranslationLanguage.korean
          ? const {'2': '우리는 학교까지 뛴다.'}
          : const {},
    );
    final verbs = await offline.find(
      'runs',
      '동사',
      translationLanguage: TranslationLanguage.korean,
    );
    expect(verbs.map((e) => e.sentence), [
      'We run to school.',
      'I run every day.',
      'They run fast.',
    ]);
    expect(verbs.first.translation, '우리는 학교까지 뛴다.');
    expect(verbs.first.sourceId, '2');
    expect(await offline.find('run', '전치사'), isEmpty);
    // 품사를 모르면 모든 품사의 예문을 찾는다.
    expect(await offline.find('run', ''), hasLength(4));

    // 내장 예문이 3개 이상이면 온라인 Tatoeba를 부르지 않는다.
    final draft = WordDraftService(
      dictionary: dictionary,
      examples: ExampleSourceService(
        client: MockClient((_) async => throw Exception('offline')),
      ),
      offline: offline,
    );
    expect(await draft.tatoebaExamples('run', '동사'), hasLength(3));
    // 해석을 원하는데 해석 있는 내장 예문이 없으면 온라인도 찾아본다(여기선 실패).
    expect(
      await WordDraftService(
        dictionary: dictionary,
        examples: ExampleSourceService(
          client: MockClient((_) async => throw Exception('offline')),
        ),
        offline: offline,
        translationLanguage: TranslationLanguage.japanese,
      ).tatoebaExamples('run', '동사'),
      hasLength(3),
    );
    // 모자라면 온라인을 시도하고, 실패해도 내장 예문은 남긴다.
    final nouns = await draft.tatoebaExamples('run', '명사');
    expect(nouns.map((e) => e.sentence), ['That was a good run.']);
  });

  test('예문 해석을 끄면 저장할 예문의 해석을 비운다', () {
    final word = service().buildWord(
      wordbookId: 'book',
      term: ' run ',
      partOfSpeech: '동사',
      meanings: ['달리다', '달리다', ''],
      examples: const [Example(sentence: 'I run.', translation: '달린다.')],
      withTranslations: false,
    );
    expect(word.term, 'run');
    expect(word.meanings, ['달리다']);
    expect(word.examples.single.translation, isEmpty);
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    OfflineExamples? offline,
  }) async {
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
          dictionaryServiceProvider.overrideWithValue(dictionary),
          exampleSourceServiceProvider.overrideWithValue(examples),
          offlineExamplesProvider.overrideWithValue(
            offline ?? noOfflineExamples,
          ),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('뜻을 고르고 그 품사의 예문을 골라 카드 한 장을 저장한다', (tester) async {
    await pumpScreen(tester, WordbookDetailScreen(book: book));
    await tester.tap(find.text('단어'));
    await tester.pumpAndSettle();
    expect(find.byType(WordAddScreen), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('word-add-term')), 'run');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('달리다'), findsOneWidget);
    expect(find.text('운영하다'), findsOneWidget);
    expect(find.text('달리기'), findsOneWidget);

    // 뜻과 예문이 한 화면에 나오고, 고른 품사(동사)의 예문만 후보가 된다.
    await tester.scrollUntilVisible(
      find.text('verb · 동사 예문'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('verb · 동사 예문'), findsOneWidget);
    expect(find.textContaining('That was a good'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('word-add-save')));
    await tester.pumpAndSettle();
    expect(find.byType(WordAddScreen), findsNothing);

    final saved = await repo.getWords(book.id);
    expect(saved, hasLength(1));
    expect(saved.single.partOfSpeech, '동사');
    expect(saved.single.meanings, ['달리다', '운영하다']);
    expect(saved.single.phonetic, '/rʌn/');
    expect(saved.single.examples.map((e) => e.sentence), [
      'We run together every morning.',
      'I run every day.',
    ]);
    expect(find.text('run'), findsWidgets);
  });

  testWidgets('같은 단어의 다른 품사는 별도 카드로 추가할 수 있다', (tester) async {
    await repo.upsertWord(
      Word(
        id: '',
        wordbookId: book.id,
        term: 'run',
        partOfSpeech: '동사',
        meanings: const ['달리다'],
        createdAt: date,
        updatedAt: date,
      ),
    );
    await pumpScreen(tester, WordAddScreen(wordbookId: book.id));
    await tester.enterText(find.byKey(const ValueKey('word-add-term')), 'run');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 이미 있는 동사 대신 명사 카드가 먼저 골라진다.
    expect(find.text('이미 덱에 있음'), findsOneWidget);
    expect(find.text('2 / 2'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('noun · 명사 예문'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('noun · 명사 예문'), findsOneWidget);
  });

  testWidgets('사전에 없는 단어는 뜻을 직접 쓰고 품사·예문 없이 등록할 수 있다', (tester) async {
    await pumpScreen(tester, WordAddScreen(wordbookId: book.id));
    await tester.enterText(find.byKey(const ValueKey('word-add-term')), 'zxqv');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('word-add-manual')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('manual-meaning')),
      '없는 말',
    );
    await tester.tap(find.byKey(const ValueKey('manual-pos-')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('추가').last);
    await tester.pumpAndSettle();
    expect(find.text('품사 모름'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('word-add-save')));
    await tester.pumpAndSettle();
    final saved = await repo.getWords(book.id);
    expect(saved.single.meanings, ['없는 말']);
    expect(saved.single.partOfSpeech, '');
  });

  testWidgets('오른쪽으로 밀어 버린 카드는 버린 카드에서 다시 넣는다', (tester) async {
    final word = await repo.upsertWord(
      Word(
        id: '',
        wordbookId: book.id,
        term: 'abandon',
        partOfSpeech: '동사',
        meanings: const ['버리다'],
        examples: const [Example(sentence: 'They had to abandon the car.')],
        createdAt: date,
        updatedAt: date,
      ),
    );
    await pumpScreen(tester, WordbookDetailScreen(book: book));
    expect(find.textContaining('had to'), findsOneWidget);

    await tester.timedDrag(
      find.text('abandon'),
      const Offset(300, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    expect(find.text("'abandon' 버림"), findsOneWidget);
    expect((await repo.getWords(book.id)).single.status, LearnStatus.completed);

    await tester.tap(find.byKey(const ValueKey('open-discarded')));
    await tester.pumpAndSettle();
    expect(find.byType(DiscardedScreen), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('restore-${word.id}')));
    await tester.pumpAndSettle();
    final restored = (await repo.getWords(book.id)).single;
    expect(restored.status, LearnStatus.learning);
    expect(Srs.isDue(restored, DateTime.now()), isTrue);
  });

  testWidgets('예문 없는 카드는 내장 예문에서 다시 찾아 넣을 수 있다', (tester) async {
    final offline = OfflineExamples(
      loadAsset: (_) async => jsonEncode({
        'sentences': {'7': 'Never abandon your friends.'},
        'index': {
          'abandon|verb': [7],
        },
      }),
    );
    final word = await repo.upsertWord(
      Word(
        id: '',
        wordbookId: book.id,
        term: 'abandon',
        partOfSpeech: '동사',
        meanings: const ['버리다'],
        createdAt: date,
        updatedAt: date,
      ),
    );
    await pumpScreen(tester, WordbookDetailScreen(book: book), offline: offline);
    expect(find.text('예문 1개 찾음'), findsOneWidget);

    await pumpScreen(tester, WordDetailScreen(word: word), offline: offline);
    expect(find.text('찾은 예문'), findsOneWidget);
    await tester.tap(find.text('예문 넣기'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.examples.single.sentence, 'Never abandon your friends.');
    expect(find.text('찾은 예문'), findsNothing);
  });
}
