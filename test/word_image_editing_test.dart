import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/home_screen.dart';
import 'package:vocabulary/screens/word_detail_screen.dart';
import 'package:vocabulary/screens/word_edit_screen.dart';
import 'package:vocabulary/screens/word_image_editor.dart';
import 'package:vocabulary/screens/wordbook_detail_screen.dart';
import 'package:vocabulary/theme.dart';

void main() {
  late LocalRepository repo;
  late Wordbook book;
  late Word word;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'seeded_v1': true});
    repo = LocalRepository();
    await repo.init();
    final date = DateTime(2026, 9, 13);
    book = await repo.createWordbook(
      Wordbook(
        id: 'book',
        ownerId: 'local',
        title: '내 단어장',
        createdAt: date,
        updatedAt: date,
      ),
    );
    word = await repo.upsertWord(
      Word(
        id: 'word',
        wordbookId: book.id,
        term: 'extraordinary',
        meaning: '비범한',
        phonetic: '/ɪkˈstrɔːrdəneri/',
        group: '기존 그룹',
        imageUrl:
            'data:image/png;base64,${base64Encode(File('web/favicon.png').readAsBytesSync())}',
        examples: const [Example(sentence: 'An extraordinary day.')],
        favorite: true,
        status: LearnStatus.learning,
        srsStage: 2,
        timesCorrect: 3,
        createdAt: date,
        updatedAt: date,
      ),
    );
  });

  Future<void> open(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(theme: buildAppTheme(), home: screen),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('목록에서 단어 편집 버튼으로 바로 수정한다', (tester) async {
    await open(tester, WordbookDetailScreen(book: book));
    await tester.tap(find.byTooltip('단어 편집'));
    await tester.pumpAndSettle();
    expect(find.byType(WordEditScreen), findsOneWidget);
    expect(find.byType(WordDetailScreen), findsNothing);
    expect(find.byType(WordImageEditor), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('섬네일은 이미지 편집만 열고 취소하면 저장하지 않는다', (tester) async {
    await open(tester, WordbookDetailScreen(book: book));
    await tester.tap(find.byTooltip('대표 이미지 편집'));
    await tester.pumpAndSettle();
    expect(find.byType(WordImageEditor), findsOneWidget);
    expect(find.byType(WordDetailScreen), findsNothing);
    expect(find.byType(WordEditScreen), findsNothing);
    await tester.tap(find.byTooltip('이미지 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect((await repo.getWords(book.id)).single.toMap(), word.toMap());
    expect(tester.takeException(), isNull);
  });

  testWidgets('이미지 저장은 최신 단어 내용과 학습 기록을 유지한다', (tester) async {
    await open(tester, WordbookDetailScreen(book: book));
    await tester.tap(find.byTooltip('대표 이미지 편집'));
    await tester.pumpAndSettle();
    final latest = await repo.upsertWord(word.copyWith(meaning: '최근에 수정한 뜻'));
    await tester.tap(find.byTooltip('이미지 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await repo.getWords(book.id)).single;
    expect(saved.imageUrl, isEmpty);
    expect(
      saved.toMap()..remove('updatedAt'),
      latest.copyWith(imageUrl: '').toMap()..remove('updatedAt'),
    );
    expect(find.byTooltip('대표 이미지 편집'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('이미지가 없는 단어도 목록 메뉴에서 이미지를 추가한다', (tester) async {
    await repo.upsertWord(word.copyWith(imageUrl: ''));
    await open(tester, WordbookDetailScreen(book: book));
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이미지 추가'));
    await tester.pumpAndSettle();
    expect(find.byType(WordImageEditor), findsOneWidget);
    expect(find.byType(WordEditScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈 대표 이미지도 이미지 편집만 연다', (tester) async {
    await open(tester, const HomeScreen());
    final image = find.byTooltip('대표 이미지 편집');
    await tester.ensureVisible(image);
    await tester.tap(image);
    await tester.pumpAndSettle();
    expect(find.byType(WordImageEditor), findsOneWidget);
    expect(find.byType(WordDetailScreen), findsNothing);
    expect(find.byType(WordEditScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
