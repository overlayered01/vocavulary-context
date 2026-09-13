import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/data/migration.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/word_detail_screen.dart';
import 'package:vocabulary/screens/word_edit_screen.dart';
import 'package:vocabulary/services/dictionary_service.dart';
import 'package:vocabulary/theme.dart';
import 'package:vocabulary/widgets/dictionary_lookup.dart';

Map<String, dynamic> sense(String definition, [String? korean]) => {
  'definition': definition,
  'translations': [
    if (korean != null)
      {
        'language': {'code': 'ko'},
        'word': korean,
      },
  ],
};

Map<String, dynamic> fixture({List<Map<String, dynamic>>? senses}) => {
  'entries': [
    {
      'language': {'code': 'en'},
      'partOfSpeech': 'verb',
      'senses':
          senses ??
          [
            sense('Move quickly on foot.', '달리다'),
            sense('Manage a company.', '운영하다'),
            sense('Function or operate.'),
          ],
    },
  ],
};

http.Response response([Map<String, dynamic>? data]) => http.Response(
  jsonEncode(data ?? fixture()),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('품사별 중첩 뜻과 해당 항목의 한국어 번역만 읽는다', () {
    final data = fixture(
      senses: [
        {
          ...sense('Move quickly on foot.', '달리다'),
          'subsenses': [sense('Move in a race.')],
        },
        sense('Move quickly on foot.', '달리다'),
      ],
    );
    (data['entries'] as List).add({
      'language': {'code': 'fr'},
      'partOfSpeech': 'verb',
      'senses': [sense('French entry')],
    });
    final result = DictionaryResult.fromMap('run', data);
    expect(result.senses.map((s) => s.meaning), ['달리다', 'Move in a race.']);
    expect(result.senses.first.partOfSpeechLabel, '동사');
    expect(result.senses.last.korean, isEmpty);
  });

  test('단어를 URL 경로 하나로 인코딩하고 같은 조회 결과를 재사용한다', () async {
    var calls = 0;
    final service = DictionaryService(
      client: MockClient((request) async {
        calls++;
        expect(request.url.pathSegments.last, 'take off / & #');
        expect(request.url.queryParameters, {'translations': 'true'});
        return response();
      }),
    );
    addTearDown(service.dispose);
    await service.lookup('  take off / & #  ');
    await service.lookup('take off / & #');
    expect(calls, 1);
  });

  test('뜻 없음과 조회 실패를 구분하며 실패 뒤에 다시 조회할 수 있다', () async {
    final responses = [
      http.Response('', 404),
      http.Response('', 429),
      http.Response('<html>unavailable</html>', 200),
      response(),
    ];
    final service = DictionaryService(
      client: MockClient((_) async => responses.removeAt(0)),
    );
    addTearDown(service.dispose);
    expect((await service.lookup('missing')).senses, isEmpty);
    await expectLater(
      service.lookup('run'),
      throwsA(isA<DictionaryLookupException>()),
    );
    await expectLater(
      service.lookup('run'),
      throwsA(isA<DictionaryLookupException>()),
    );
    expect((await service.lookup('run')).senses.length, 3);
  });

  final date = DateTime(2026, 9, 13);
  late LocalRepository repo;
  late Wordbook book;
  late DictionaryService service;

  setUp(() async {
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
    service = DictionaryService(client: MockClient((_) async => response()));
  });
  tearDown(() => service.dispose());

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          dictionaryServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => screen),
                ),
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label,
  );

  Future<void> lookup(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('사전 뜻 보기'));
    await tester.tap(find.text('사전 뜻 보기'));
    await tester.pumpAndSettle();
  }

  testWidgets('직접 쓴 뜻에 선택한 사전 뜻만 추가하고 출처와 품사를 저장한다', (tester) async {
    await open(tester, WordEditScreen(wordbookId: book.id));
    await tester.enterText(field('단어 *'), 'run');
    await tester.enterText(field('뜻 *'), '내가 기억할 뜻');
    await lookup(tester);
    expect(find.text('Move quickly on foot.'), findsOneWidget);
    await tester.tap(find.text('달리다'));
    await tester.tap(find.text('운영하다'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택한 뜻 추가 (2)'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field('뜻 1')).controller!.text, '내가 기억할 뜻');
    expect(tester.widget<TextField>(field('뜻 2')).controller!.text, '달리다');

    // Reopening uses the current draft and disables meanings already added.
    await lookup(tester);
    final savedTile = find.ancestor(
      of: find.text('달리다'),
      matching: find.byType(CheckboxListTile),
    );
    expect(tester.widget<CheckboxListTile>(savedTile).onChanged, isNull);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.meanings, ['내가 기억할 뜻', '달리다', '운영하다']);
    expect(saved.partOfSpeech, '동사');
    expect(saved.dictionarySourceTerms, ['run']);
    await importSharedWordbook(repo, book, [
      saved.copyWith(term: 'Run', meanings: ['내가 편집한 뜻']),
    ]);
    final imported = (await repo.getWordbooks()).firstWhere(
      (b) => b.id != book.id,
    );
    expect((await repo.getWords(imported.id)).single.dictionarySourceTerms, [
      'run',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('상세 화면에서 조회만 하면 저장하지 않고 추가할 때 최신 내용을 유지한다', (tester) async {
    final word = await repo.upsertWord(
      Word(
        id: 'word',
        wordbookId: book.id,
        term: 'run',
        meanings: const ['직접 쓴 뜻'],
        partOfSpeech: '명사',
        srsStage: 3,
        timesCorrect: 4,
        createdAt: date,
        updatedAt: date,
      ),
    );
    await open(tester, WordDetailScreen(word: word));
    await lookup(tester);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect((await repo.getWords(book.id)).single.toMap(), word.toMap());
    await lookup(tester);
    await repo.upsertWord(
      word.copyWith(meanings: ['최근에 수정한 뜻'], imageUrl: 'latest-image'),
    );
    await tester.tap(find.text('달리다'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택한 뜻 추가 (1)'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.meanings, ['최근에 수정한 뜻', '달리다']);
    expect(saved.imageUrl, 'latest-image');
    expect(saved.partOfSpeech, '명사');
    expect(saved.srsStage, 3);
    expect(saved.timesCorrect, 4);
    expect(saved.dictionarySourceTerms, ['run']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('조회 실패 후 재시도하고 많은 사전 뜻을 스크롤해서 고른다', (tester) async {
    service.dispose();
    var requests = 0;
    service = DictionaryService(
      client: MockClient((_) async {
        requests++;
        return requests == 1
            ? http.Response('', 503)
            : response(
                fixture(
                  senses: [
                    for (var i = 0; i < 40; i++)
                      sense('Dictionary definition $i.'),
                  ],
                ),
              );
      }),
    );
    DictionarySelection? selected;
    await open(
      tester,
      Scaffold(
        body: DictionaryLookupButton(
          term: 'run',
          meanings: () => [],
          onSelected: (value) async => selected = value,
        ),
      ),
    );
    await lookup(tester);
    expect(find.text('다시 시도'), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Dictionary definition 39.'),
      350,
      scrollable: find
          .descendant(
            of: find.byType(Dialog),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Dictionary definition 39.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택한 뜻 추가 (1)'));
    await tester.pumpAndSettle();
    expect(selected!.senses.single.meaning, 'Dictionary definition 39.');
    expect(requests, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('조회 중 창을 닫아도 늦게 온 결과가 다음 단어에 섞이지 않는다', (tester) async {
    service.dispose();
    final pending = Completer<http.Response>();
    final queries = <String>[];
    service = DictionaryService(
      client: MockClient((request) {
        final term = request.url.pathSegments.last;
        queries.add(term);
        return term == 'run'
            ? pending.future
            : Future.value(
                response(fixture(senses: [sense('An apple.', '사과')])),
              );
      }),
    );
    await open(tester, WordEditScreen(wordbookId: book.id));
    await tester.enterText(field('단어 *'), 'run');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('사전 뜻 보기'));
    await tester.tap(find.text('사전 뜻 보기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      field('단어 *'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(field('단어 *'), 'apple');
    await lookup(tester);
    pending.complete(response());
    await tester.pumpAndSettle();
    expect(find.text('사과'), findsOneWidget);
    expect(find.text('달리다'), findsNothing);
    expect(queries, ['run', 'apple']);
    await tester.tap(find.text('사과'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택한 뜻 추가 (1)'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      field('뜻 *'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<TextField>(field('뜻 *')).controller!.text, '사과');
    expect(tester.takeException(), isNull);
  });
}
