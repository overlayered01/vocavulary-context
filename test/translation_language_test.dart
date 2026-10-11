import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/models/app_settings.dart';
import 'package:vocabulary/models/translation_language.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/settings_screen.dart';
import 'package:vocabulary/screens/word_edit_screen.dart';
import 'package:vocabulary/services/dictionary_service.dart';
import 'package:vocabulary/services/example_source_service.dart';
import 'package:vocabulary/services/word_draft_service.dart';
import 'package:vocabulary/theme.dart';
import 'package:vocabulary/widgets/translation_language_dropdown.dart';

Map<String, dynamic> dictionaryData() => {
  'entries': [
    {
      'language': {'code': 'en'},
      'partOfSpeech': 'adjective',
      'senses': [
        {
          'definition': 'Feeling pleasure.',
          'translations': [
            {
              'language': {'code': 'ko'},
              'word': '행복한',
            },
            {
              'language': {'code': 'ja'},
              'word': '幸せな',
            },
          ],
        },
      ],
    },
  ],
};

void main() {
  test('이전 설정의 기본 언어와 선택 언어 저장·복원을 유지한다', () async {
    expect(
      AppSettings.fromMap({}).translationLanguage,
      TranslationLanguage.korean,
    );
    expect(
      AppSettings.fromMap({
        'translationLanguage': 'unknown',
      }).translationLanguage,
      TranslationLanguage.korean,
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await const AppSettings()
        .copyWith(translationLanguage: TranslationLanguage.japanese)
        .save(prefs);
    expect(
      (await AppSettings.load(prefs)).translationLanguage,
      TranslationLanguage.japanese,
    );
  });

  test('사전 뜻과 캐시는 선택한 언어를 구분하고 없는 번역은 영어로 표시한다', () async {
    var requests = 0;
    final dictionary = DictionaryService(
      client: MockClient((_) async {
        requests++;
        return http.Response(
          jsonEncode(dictionaryData()),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(dictionary.dispose);
    expect((await dictionary.lookup('happy')).senses.single.meaning, '행복한');
    expect(
      (await dictionary.lookup(
        'happy',
        translationLanguage: TranslationLanguage.japanese,
      )).senses.single.meaning,
      '幸せな',
    );
    expect(
      (await dictionary.lookup(
        'happy',
        translationLanguage: TranslationLanguage.french,
      )).senses.single.meaning,
      'Feeling pleasure.',
    );
    await dictionary.lookup(
      'happy',
      translationLanguage: TranslationLanguage.japanese,
    );
    expect(requests, 3);
  });

  test('예문 조회·동시 요청·캐시에서 번역 언어를 분리한다', () async {
    final requests = <String>[];
    final service = ExampleSourceService(
      client: MockClient((request) async {
        final language = request.url.queryParameters['showtrans:lang']!;
        requests.add(language);
        expect(request.url.queryParameters['trans:lang'], language);
        return http.Response(
          jsonEncode({
            'data': [
              {
                'text': 'I am happy.',
                'translations': [
                  {'lang': 'kor', 'text': '행복해요.'},
                  {'lang': 'jpn', 'text': '幸せです。'},
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(service.dispose);
    final values = await Future.wait([
      service.fetchExamples('happy', limit: 1),
      service.fetchExamples(
        'happy',
        limit: 1,
        translationLanguage: TranslationLanguage.japanese,
      ),
      service.fetchExamples(
        'happy',
        limit: 1,
        translationLanguage: TranslationLanguage.japanese,
      ),
    ]);
    expect(values[0].single.translation, '행복해요.');
    expect(values[1].single.translation, '幸せです。');
    expect(values[2].single.translation, '幸せです。');
    await service.fetchExamples(
      'happy',
      limit: 1,
      translationLanguage: TranslationLanguage.japanese,
    );
    expect(requests, ['kor', 'jpn']);
  });

  test('번역이 없는 언어는 영어 풀이로 채우고 영어 풀이임을 표시한다', () async {
    final dictionary = DictionaryService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(dictionaryData()),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    final examples = ExampleSourceService(
      client: MockClient((_) async => http.Response('{"data":[]}', 200)),
    );
    addTearDown(dictionary.dispose);
    addTearDown(examples.dispose);
    final service = WordDraftService(
      dictionary: dictionary,
      examples: examples,
      translationLanguage: TranslationLanguage.french,
    );
    final lookup = await service.lookup('happy');
    expect(lookup.groups.first.meanings.first, 'Feeling pleasure.');
    expect(lookup.groups.first.englishOnly, isTrue);
    final word = service.buildWord(
      wordbookId: 'b',
      term: 'happy',
      partOfSpeech: lookup.groups.first.partOfSpeech,
      meanings: lookup.groups.first.meanings,
      examples: const [],
    );
    expect(Word.fromMap(word.toMap()).translationLanguage, 'fr');
    expect(word.copyWith(favorite: true).translationLanguage, 'fr');
  });

  testWidgets('설정에서 선택한 번역 언어를 저장한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // 언어 목록 전체가 메뉴에 그려지도록 화면을 크게 둔다.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TranslationLanguageDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('일본어').last);
    await tester.pumpAndSettle();
    expect(
      (await AppSettings.load(prefs)).translationLanguage,
      TranslationLanguage.japanese,
    );
    await tester.tap(find.byType(TranslationLanguageDropdown));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('자동 · ').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('자동 · ').last);
    await tester.pumpAndSettle();
    expect((await AppSettings.load(prefs)).translationLanguageOverride, isNull);
    expect(tester.takeException(), isNull);
  });

  test('번역 언어 자동 선택은 기기 언어, 다음으로 국가를 따른다', () {
    expect(
      TranslationLanguage.fromLocale(const Locale('ja', 'JP')),
      TranslationLanguage.japanese,
    );
    expect(
      TranslationLanguage.fromLocale(const Locale('en', 'BR')),
      TranslationLanguage.english,
    );
    expect(
      TranslationLanguage.fromLocale(const Locale('ca', 'ES')),
      TranslationLanguage.spanish,
    );
    expect(
      TranslationLanguage.fromLocale(const Locale('in')),
      TranslationLanguage.indonesian,
    );
    expect(
      TranslationLanguage.fromLocale(const Locale('en', 'US')),
      TranslationLanguage.english,
    );
    expect(
      TranslationLanguage.fromLocale(const Locale('ru', 'RU')),
      TranslationLanguage.korean,
    );
    expect(
      AppSettings.fromMap({}).toMap().containsKey('translationLanguage'),
      isFalse,
    );
  });

  testWidgets('입력칸에 작성 예시를 두지 않고 일본어 팝업의 빈 예문을 저장하지 않는다', (tester) async {
    SharedPreferences.setMockInitialValues({'seeded_v1': true});
    final repo = LocalRepository();
    await repo.init();
    final date = DateTime(2026);
    final book = await repo.createWordbook(
      Wordbook(
        id: '',
        ownerId: '',
        title: '테스트',
        createdAt: date,
        updatedAt: date,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          initialSettingsProvider.overrideWithValue(
            const AppSettings(
              translationLanguage: TranslationLanguage.japanese,
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: WordEditScreen(wordbookId: book.id),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final term = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == '단어 *',
    );
    expect(tester.widget<TextField>(term).controller!.text, isEmpty);
    expect(find.textContaining('happy'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('직접 추가'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(WordEditScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('직접 추가')),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('직접 추가'));
    await tester.pumpAndSettle();
    final sentence = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == '영어 문장 *',
    );
    expect(tester.widget<TextField>(sentence).controller!.text, isEmpty);
    expect(find.textContaining('I am happy today.'), findsNothing);
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    expect(find.text('영어 문장을 입력해 주세요.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(await repo.getWords(book.id), isEmpty);
    expect(tester.takeException(), isNull);
  });
}
