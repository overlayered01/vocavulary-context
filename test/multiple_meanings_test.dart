import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/data/migration.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/word_edit_screen.dart';
import 'package:vocabulary/screens/wordbook_detail_screen.dart';
import 'package:vocabulary/theme.dart';
import 'package:vocabulary/widgets/dictionary_links.dart';

void main() {
  final date = DateTime(2026, 9, 13);
  late LocalRepository repo;
  late Wordbook book;

  Word exampleWord({String id = 'word'}) => Word(
    id: id,
    wordbookId: book.id,
    term: 'run',
    meanings: const ['달리다', '운영하다', '작동하다'],
    partOfSpeech: '동사',
    examples: const [Example(sentence: 'I run a business.')],
    srsStage: 2,
    timesCorrect: 3,
    createdAt: date,
    updatedAt: date,
  );

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
  });

  test('이전 뜻은 쉼표를 포함해 원문 그대로 보존한다', () {
    final old = exampleWord().toMap()..remove('meanings');
    old['meaning'] = '중요한, 상당한';
    final restored = Word.fromMap(old);
    expect(restored.meanings, ['중요한, 상당한']);
    expect(Word.fromMap(restored.toMap()).meanings, restored.meanings);
  });

  test('여러 뜻의 순서와 구두점은 유지하고 빈 값과 중복만 정리한다', () {
    final word = exampleWord().copyWith(
      meanings: [' 달리다 ', '', '달리다', '운영하다 (회사, 사업)', '작동하다'],
    );
    expect(Word.fromMap(word.toMap()).meanings, [
      '달리다',
      '운영하다 (회사, 사업)',
      '작동하다',
    ]);
    expect(word.copyWith(imageUrl: 'updated').meanings, word.meanings);
    expect(word.copyWith(timesCorrect: 4).meanings, word.meanings);
  });

  test('신규 단어 저장과 공유 단어장 복제에서 모든 뜻을 보존한다', () async {
    final created = await repo.upsertWord(exampleWord(id: ''));
    expect((await repo.getWords(book.id)).single.meanings, created.meanings);
    await importSharedWordbook(repo, book, [created]);
    final imported = (await repo.getWordbooks()).firstWhere(
      (b) => b.id != book.id,
    );
    expect(
      (await repo.getWords(imported.id)).single.meanings,
      created.meanings,
    );
  });

  test('사전 링크의 검색어에 공백과 특수문자가 들어가도 유지한다', () {
    const term = 'take off & go #1';
    for (final source in [
      DictionarySource.cambridge,
      DictionarySource.oxford,
    ]) {
      expect(source.searchUri(term).queryParameters['q'], term);
      expect(source.searchUri(term).scheme, 'https');
    }
    expect(
      DictionarySource.naver.searchUri(term).toString().split('#').last,
      '/search?query=${Uri.encodeComponent(term)}',
    );
  });

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => screen)),
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
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );

  testWidgets('단어 하나에 뜻을 따로 추가하고 품사와 함께 저장한다', (tester) async {
    await open(tester, WordEditScreen(wordbookId: book.id));
    await tester.enterText(field('단어 *'), 'run');
    await tester.enterText(field('뜻 *'), '달리다');
    await tester.tap(find.text('뜻 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(field('뜻 2'), '운영하다');
    final part = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(part);
    await tester.tap(part);
    await tester.pumpAndSettle();
    await tester.tap(find.text('동사').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.meanings, ['달리다', '운영하다']);
    expect(saved.partOfSpeech, '동사');
    expect(tester.takeException(), isNull);
  });

  testWidgets('가운데 뜻만 삭제하고 나머지 뜻과 학습 기록을 유지한다', (tester) async {
    final word = await repo.upsertWord(exampleWord());
    await open(tester, WordEditScreen(wordbookId: book.id, existing: word));
    await tester.tap(find.byTooltip('뜻 2 삭제'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field('뜻 2')).controller?.text, '작동하다');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.meanings, ['달리다', '작동하다']);
    expect(saved.srsStage, 2);
    expect(saved.timesCorrect, 3);
    expect(saved.examples.single.sentence, word.examples.single.sentence);
    expect(tester.takeException(), isNull);
  });

  testWidgets('목록의 뜻 수정도 개별 항목으로 저장한다', (tester) async {
    await repo.upsertWord(exampleWord());
    await open(tester, WordbookDetailScreen(book: book));
    await tester.tap(find.text('1. 달리다'));
    await tester.pumpAndSettle();
    await tester.enterText(field('뜻 2'), '경영하다');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect((await repo.getWords(book.id)).single.meanings, [
      '달리다',
      '경영하다',
      '작동하다',
    ]);
    expect(find.text('2. 경영하다'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('빈 뜻으로 저장하지 않고 작성 중인 단어로 사전 링크를 갱신한다', (tester) async {
    await open(tester, WordEditScreen(wordbookId: book.id));
    await tester.enterText(field('단어 *'), 'take off');
    await tester.pump();
    expect(
      tester.widget<DictionaryLinks>(find.byType(DictionaryLinks)).term,
      'take off',
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(await repo.getWords(book.id), isEmpty);
    expect(find.text('단어와 뜻을 하나 이상 입력해 주세요.'), findsOneWidget);
  });
}
