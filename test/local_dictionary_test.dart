import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vocabulary/models/translation_language.dart';
import 'package:vocabulary/services/dictionary_service.dart';
import 'package:vocabulary/services/example_source_service.dart';
import 'package:vocabulary/services/local_dictionary.dart';
import 'package:vocabulary/services/word_draft_service.dart';
import 'package:vocabulary/widgets/dictionary_lookup.dart';

/// 내장 사전 파일과 같은 형식의 작은 사전.
LocalDictionary fakeDictionary() => LocalDictionary(
  loadAsset: (path) async {
    if (path != 'assets/dictionaries/ko.json') throw StateError(path);
    return jsonEncode({
      'redirects': {'bore': 'bear', 'take': 'nope'},
      'entries': {
        'take': [
          [
            'verb',
            ['잡다, 쥐다', '가져가다', '(시간이) 걸리다', '(사진) 찍다'],
          ],
          [
            'noun',
            ['취득'],
          ],
        ],
        'go': [
          [
            'verb',
            ['가다'],
          ],
        ],
        'bear': [
          [
            'verb',
            ['견디다'],
          ],
        ],
        'service': [
          [
            'noun',
            ['서비스'],
          ],
        ],
      },
    });
  },
);

http.Response remoteTake() => http.Response(
  jsonEncode({
    'entries': [
      {
        'language': {'code': 'en'},
        'partOfSpeech': 'verb',
        'pronunciations': [
          {'type': 'ipa', 'text': '/teɪk/'},
        ],
        'senses': [
          {'definition': 'To get into one\'s hands.'},
          {
            'definition': 'To receive or accept.',
            'translations': [
              {
                'language': {'code': 'ko'},
                'word': '받아들이다',
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

void main() {
  test('활용형은 기본형 후보로 다시 찾는다', () {
    expect(baseForms('went'), contains('go'));
    expect(baseForms('services'), contains('service'));
    expect(baseForms('running'), contains('run'));
    expect(baseForms('studies'), contains('study'));
    expect(baseForms('liked'), contains('like'));
    expect(baseForms('take'), isNot(contains('take')));
  });

  test('내장 사전에서 단어와 기본형을 찾고, 없는 언어는 비워 둔다', () async {
    final dictionary = fakeDictionary();
    final take = await dictionary.lookup(' Take ', TranslationLanguage.korean);
    expect(take.first.glosses.first, '잡다, 쥐다');
    expect(take.map((e) => e.partOfSpeech), ['verb', 'noun']);
    final went = await dictionary.lookup('went', TranslationLanguage.korean);
    expect(went.single.headword, 'go');
    // 사전이 알려준 기본형(bore → bear)을 따르되, 뜻이 있는 단어는 그대로 쓴다.
    final bore = await dictionary.lookup('bore', TranslationLanguage.korean);
    expect(bore.single.headword, 'bear');
    expect(take.first.headword, 'take');
    // 내장 사전이 없는 언어는 온라인 사전만 쓴다.
    expect(
      await dictionary.lookup('take', TranslationLanguage.french),
      isEmpty,
    );
    expect(
      await dictionary.lookup('zzzz', TranslationLanguage.korean),
      isEmpty,
    );
  });

  test('사전 파일을 읽지 못하면 온라인 사전만 쓴다', () async {
    final dictionary = LocalDictionary(
      loadAsset: (_) async => throw StateError('missing'),
    );
    expect(
      await dictionary.lookup('take', TranslationLanguage.korean),
      isEmpty,
    );
  });

  test('내장 사전 뜻을 앞에, 온라인 뜻을 뒤에 합치고 중복은 뺀다', () async {
    final service = DictionaryService(
      client: MockClient((_) async => remoteTake()),
      local: fakeDictionary(),
    );
    addTearDown(service.dispose);
    final result = await service.lookup('take');
    expect(result.senses.take(5).map((s) => s.meaning), [
      '잡다, 쥐다',
      '가져가다',
      '(시간이) 걸리다',
      '(사진) 찍다',
      '취득',
    ]);
    expect(result.senses.first.source, 'ko');
    expect(result.senses.first.sourceTerm('take'), 'ko:take');
    expect(result.senses.map((s) => s.meaning), contains('받아들이다'));
    expect(result.phonetic, '/teɪk/');
  });

  test('온라인 사전이 실패하거나 늦어도 내장 사전 뜻은 돌려준다', () async {
    final failing = DictionaryService(
      client: MockClient((_) async => http.Response('', 503)),
      local: fakeDictionary(),
    );
    addTearDown(failing.dispose);
    expect((await failing.lookup('take')).senses.first.meaning, '잡다, 쥐다');

    final pending = Completer<http.Response>();
    final slow = DictionaryService(
      client: MockClient((_) => pending.future),
      local: fakeDictionary(),
    );
    addTearDown(slow.dispose);
    final result = await slow.lookup(
      'take',
      remoteTimeout: const Duration(milliseconds: 50),
    );
    expect(result.senses.first.meaning, '잡다, 쥐다');
    expect(result.phonetic, isEmpty);
    pending.complete(remoteTake());
  });

  test('자동 뜻 입력은 내장 사전의 기본 뜻을 쓰고 출처를 남긴다', () async {
    final dictionary = DictionaryService(
      client: MockClient((_) async => remoteTake()),
      local: fakeDictionary(),
    );
    final examples = ExampleSourceService(
      client: MockClient((_) async => http.Response('{"data":[]}', 200)),
    );
    addTearDown(dictionary.dispose);
    addTearDown(examples.dispose);
    final lookup = await WordDraftService(
      dictionary: dictionary,
      examples: examples,
    ).lookup('take');
    final verb = lookup.groups.first;
    expect(verb.partOfSpeech, '동사');
    expect(verb.meanings.take(3), ['잡다, 쥐다', '가져가다', '(시간이) 걸리다']);
    expect(verb.sourceTerms['잡다, 쥐다'], 'ko:take');
    expect(lookup.phonetic, '/teɪk/');
    expect(lookup.failed, isFalse);
  });

  test('내장 사전 예문은 품사별로 붙고 번역을 함께 가진다', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final entries = await LocalDictionary().lookup(
      'clean',
      TranslationLanguage.korean,
    );
    final verb = entries.firstWhere((e) => e.partOfSpeech == 'verb');
    expect(verb.examples, isNotEmpty);
    final (sentence, translation) = verb.examples.first;
    expect(sentence, contains('clean'));
    expect(translation, matches(RegExp('[가-힣]')));
  });

  testWidgets('출처 표시는 한국어판·영어판 Wiktionary를 구분한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DictionaryAttribution(terms: ['ko:take', 'take'])),
      ),
    );
    expect(find.text('Wiktionary (ko) · take'), findsOneWidget);
    expect(find.text('Wiktionary · take'), findsOneWidget);
    expect(find.text('Kaikki.org'), findsOneWidget);
    expect(find.text('FreeDictionaryAPI.com'), findsOneWidget);
  });

  test('앱에 들어간 한국어·일본어·중국어 사전 파일을 읽을 수 있다', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dictionary = LocalDictionary();
    final ko = await dictionary.lookup('take', TranslationLanguage.korean);
    expect(ko.first.partOfSpeech, 'verb');
    expect(ko.first.glosses.first, contains('잡다'));
    final ja = await dictionary.lookup('happy', TranslationLanguage.japanese);
    expect(ja.first.glosses.first, '幸せな');
    // 중국어판은 번체가 많아 간체로 바꿔 넣는다.
    final zh = await dictionary.lookup('happy', TranslationLanguage.chinese);
    expect(zh.first.glosses.first, contains('快乐'));
    final went = await dictionary.lookup('went', TranslationLanguage.japanese);
    expect(went.first.headword, 'go');
  });
}
