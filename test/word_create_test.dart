import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/home_screen.dart';
import 'package:vocabulary/screens/word_create_screen.dart';
import 'package:vocabulary/screens/word_edit_screen.dart';
import 'package:vocabulary/screens/wordbook_detail_screen.dart';
import 'package:vocabulary/services/dictionary_service.dart';
import 'package:vocabulary/services/example_source_service.dart';
import 'package:vocabulary/services/word_draft_service.dart';
import 'package:vocabulary/theme.dart';
import 'package:vocabulary/widgets/add_word_button.dart';

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
            'examples': ['We run together.'],
            'subsenses': [
              {'definition': 'A closely related way to move quickly.'},
            ],
          },
          {
            'definition': 'An outdated usage.',
            'tags': ['archaic'],
            'subsenses': [
              {'definition': 'A more specific outdated usage.'},
            ],
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
          {'definition': 'Another meaning.'},
        ],
      },
      {
        'language': {'code': 'en'},
        'partOfSpeech': 'noun',
        'senses': [
          {'definition': 'An act of running.'},
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
        'text': 'We run a shop.',
        'translations': [
          {'lang': 'kor', 'text': '우리는 가게를 운영한다.'},
        ],
      },
    ],
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late DictionaryService dictionary;
  late ExampleSourceService examples;
  late LocalRepository repo;
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

  Future<WordDraft> draft({List<Word> saved = const []}) => WordDraftService(
    dictionary: dictionary,
    examples: examples,
  ).create(term: ' run ', wordbookId: book.id, savedWords: saved);

  test('사전의 일반적인 뜻과 품사·발음·한국어 예문을 초안에 채운다', () async {
    final result = await draft();
    expect(result.word.term, 'run');
    expect(result.word.meanings, ['달리다', '운영하다', 'Function or operate.']);
    expect(result.word.partOfSpeech, '동사');
    expect(result.word.phonetic, '/rʌn/');
    expect(result.word.examples.map((e) => e.translation), [
      '나는 매일 달린다.',
      '우리는 가게를 운영한다.',
    ]);
    expect(result.word.dictionarySourceTerms, ['run']);
    expect(await repo.getWords(book.id), isEmpty);
  });

  test('같은 단어의 최신 저장 내용을 참고하지만 학습 상태는 새로 시작한다', () async {
    var requests = 0;
    dictionary.dispose();
    examples.dispose();
    dictionary = DictionaryService(
      client: MockClient((_) async {
        requests++;
        return dictionaryResponse();
      }),
    );
    examples = ExampleSourceService(
      client: MockClient((_) async {
        requests++;
        return examplesResponse();
      }),
    );
    final original = Word(
      id: 'old-word',
      wordbookId: 'old-book',
      term: 'RUN',
      meanings: const ['내가 고른 뜻'],
      partOfSpeech: '동사',
      phonetic: '/rʌn/',
      imageUrl: 'saved-image',
      dictionarySourceTerms: const ['run'],
      examples: const [
        Example(sentence: 'First example.'),
        Example(sentence: 'Second example.'),
      ],
      favorite: true,
      srsStage: 3,
      timesCorrect: 5,
      status: LearnStatus.completed,
      createdAt: date,
      updatedAt: date,
    );
    final result = await draft(
      saved: [
        original.copyWith(
          meanings: ['예전 뜻'],
          updatedAt: date.subtract(const Duration(days: 1)),
        ),
        original,
      ],
    );
    expect(requests, 0);
    expect(result.word.meanings, original.meanings);
    expect(result.word.imageUrl, original.imageUrl);
    expect(result.word.dictionarySourceTerms, original.dictionarySourceTerms);
    expect(result.word.id, isEmpty);
    expect(result.word.wordbookId, book.id);
    expect(result.word.srsStage, 0);
    expect(result.word.status, LearnStatus.fresh);
    expect(result.word.timesCorrect, 0);
  });

  test('예문 서버 실패 시 사전 예문을 사용하고 사전 실패 시에는 예문을 보존한다', () async {
    examples.dispose();
    examples = ExampleSourceService(
      client: MockClient((_) async => http.Response('', 503)),
    );
    final withDictionary = await draft();
    expect(withDictionary.word.meanings, isNotEmpty);
    expect(withDictionary.word.examples.single.sentence, 'We run together.');
    expect(withDictionary.word.examples.single.source, 'Wiktionary');
    dictionary.dispose();
    examples.dispose();
    dictionary = DictionaryService(
      client: MockClient((_) async => http.Response('', 503)),
    );
    examples = ExampleSourceService(
      client: MockClient((_) async => examplesResponse()),
    );
    final withExamples = await draft();
    expect(withExamples.word.meanings, isEmpty);
    expect(withExamples.word.examples.length, 2);
    expect(withExamples.notice, contains('사전에 연결하지 못했어요'));
  });

  test('느린 예문 응답을 기다리지 않고 사전 초안을 반환한다', () async {
    examples.dispose();
    final pending = Completer<http.Response>();
    examples = ExampleSourceService(client: MockClient((_) => pending.future));
    final result = await draft().timeout(const Duration(seconds: 1));
    expect(result.word.meanings.first, '달리다');
    expect(result.word.examples.single.source, 'Wiktionary');
    expect(result.pendingExamples, isNotNull);
    pending.complete(examplesResponse());
    expect((await result.pendingExamples!).first.translation, '나는 매일 달린다.');
  });

  Future<void> open(WidgetTester tester, {Widget? screen}) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          dictionaryServiceProvider.overrideWithValue(dictionary),
          exampleSourceServiceProvider.overrideWithValue(examples),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: screen ?? WordbookDetailScreen(book: book),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AddWordButton));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );

  Future<void> create(WidgetTester tester) async {
    await tester.enterText(field('단어'), 'run');
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
  }

  testWidgets('단어 추가는 입력 하나로 시작하고 자동 작성 후 수정·저장하면 목록으로 돌아온다', (tester) async {
    await repo.createWordbook(
      Wordbook(
        id: 'other',
        ownerId: 'local',
        title: '다른 단어장',
        createdAt: date,
        updatedAt: date,
      ),
    );
    await open(tester);
    expect(find.byType(WordCreateScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('저장'), findsNothing);
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .value,
      book.id,
    );
    await create(tester);
    expect(find.byType(WordEditScreen), findsOneWidget);
    expect(tester.widget<TextField>(field('뜻 1')).controller!.text, '달리다');
    expect(
      tester
          .widget<WordEditScreen>(find.byType(WordEditScreen))
          .initialDraft!
          .phonetic,
      '/rʌn/',
    );
    expect(await repo.getWords(book.id), isEmpty);
    await tester.enterText(field('뜻 1'), '빠르게 달리다');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.byType(WordCreateScreen), findsNothing);
    expect(find.byType(WordEditScreen), findsNothing);
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.meanings.first, '빠르게 달리다');
    expect(saved.examples.length, 2);
    expect(saved.dictionarySourceTerms, ['run']);
    expect(find.text('run'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈에서 단어장 선택과 입력을 함께 하고 선택한 단어장에 저장한다', (tester) async {
    final second = await repo.createWordbook(
      Wordbook(
        id: 'second',
        ownerId: 'local',
        title: '다른 단어장',
        createdAt: date,
        updatedAt: date,
      ),
    );
    await open(tester, screen: const HomeScreen());
    expect(find.byType(WordCreateScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(SimpleDialog), findsNothing);
    final picker = find.byType(DropdownButtonFormField<String>);
    final initial = tester.state<FormFieldState<String>>(picker).value;
    final destination = initial == book.id ? second : book;
    await tester.enterText(field('단어'), 'run');
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text(destination.title).last);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field('단어')).controller!.text, 'run');
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    final editor = tester.widget<WordEditScreen>(find.byType(WordEditScreen));
    expect(editor.wordbookId, destination.id);
    expect(editor.wordbookTitle, destination.title);
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect((await repo.getWords(destination.id)).single.term, 'run');
    expect(await repo.getWords(initial!), isEmpty);
    expect(find.byType(WordCreateScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('검색 결과가 없어도 단어를 유지하고 직접 작성해 저장할 수 있다', (tester) async {
    dictionary.dispose();
    examples.dispose();
    dictionary = DictionaryService(
      client: MockClient((_) async => http.Response('', 404)),
    );
    examples = ExampleSourceService(
      client: MockClient((_) async => http.Response('{"data":[]}', 200)),
    );
    await open(tester);
    await create(tester);
    expect(find.textContaining('뜻을 찾지 못했어요'), findsOneWidget);
    expect(tester.widget<TextField>(field('단어 *')).controller!.text, 'run');
    await tester.enterText(field('뜻 *'), '내가 작성한 뜻');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect((await repo.getWords(book.id)).single.meanings, ['내가 작성한 뜻']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('자동 작성 도중 나가면 늦게 도착한 결과로 화면을 열거나 저장하지 않는다', (tester) async {
    dictionary.dispose();
    final pending = Completer<http.Response>();
    dictionary = DictionaryService(client: MockClient((_) => pending.future));
    await open(tester);
    await tester.enterText(field('단어'), 'run');
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pageBack();
    await tester.pumpAndSettle();
    pending.complete(dictionaryResponse());
    await tester.pumpAndSettle();
    expect(find.byType(WordCreateScreen), findsNothing);
    expect(find.byType(WordEditScreen), findsNothing);
    expect(await repo.getWords(book.id), isEmpty);
    expect(tester.takeException(), isNull);
  });

  Future<Completer<http.Response>> openWithSlowExamples(
    WidgetTester tester,
  ) async {
    examples.dispose();
    final pending = Completer<http.Response>();
    examples = ExampleSourceService(client: MockClient((_) => pending.future));
    await open(tester);
    await tester.enterText(field('단어'), 'run');
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WordEditScreen), findsOneWidget);
    expect(tester.widget<TextField>(field('뜻 1')).controller!.text, '달리다');
    return pending;
  }

  testWidgets('사전 뜻을 먼저 보여주고 도착한 예문을 나중에 채운다', (tester) async {
    final pending = await openWithSlowExamples(tester);
    pending.complete(examplesResponse());
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.examples.first.sentence, 'I run every day.');
    expect(saved.examples.first.translation, '나는 매일 달린다.');
    expect(tester.takeException(), isNull);
  });

  testWidgets('나중에 온 예문이 직접 작성한 내용을 덮어쓰지 않는다', (tester) async {
    final pending = await openWithSlowExamples(tester);
    await tester.scrollUntilVisible(
      field('영어 문장'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(WordEditScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(field('영어 문장').first, 'My own example.');
    pending.complete(examplesResponse());
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(
      (await repo.getWords(book.id)).single.examples.first.sentence,
      'My own example.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('예문을 기다리지 않고 저장하며 늦은 응답은 저장 내용을 바꾸지 않는다', (tester) async {
    final pending = await openWithSlowExamples(tester);
    await tester.enterText(field('뜻 1'), '내가 고른 뜻');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.byType(WordEditScreen), findsNothing);
    final before = (await repo.getWords(book.id)).single.toMap();
    pending.complete(examplesResponse());
    await tester.pumpAndSettle();
    expect((await repo.getWords(book.id)).single.toMap(), before);
    expect(tester.takeException(), isNull);
  });
}
