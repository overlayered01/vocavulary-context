import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/data/srs.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/models/wordbook.dart';
import 'package:vocabulary/providers.dart';

/// 복습 화면처럼 단어를 버린 뒤 invalidateData만 부르는 경우에도,
/// 열려 있는 단어장 화면(wordsProvider)의 남은 장수가 갱신돼야 한다.
void main() {
  final date = DateTime(2026, 11, 7);

  testWidgets('카드를 버리고 invalidateData를 부르면 단어장별 남은 장수도 갱신된다', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'seeded_v1': true});
    final repo = LocalRepository();
    await repo.init();
    final book = await repo.createWordbook(
      Wordbook(
        id: 'book',
        ownerId: 'local',
        title: 'Default',
        createdAt: date,
        updatedAt: date,
      ),
    );
    final word = await repo.upsertWord(
      Word(
        id: 'w1',
        wordbookId: book.id,
        term: 'welcome',
        meanings: const ['used to greet someone'],
        createdAt: date,
        updatedAt: date,
      ),
    );
    await repo.upsertWord(
      Word(
        id: 'w2',
        wordbookId: book.id,
        term: 'resilient',
        meanings: const ['able to recover quickly'],
        createdAt: date,
        updatedAt: date,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              final words =
                  ref.watch(wordsProvider(book.id)).asData?.value ?? const [];
              final left = words
                  .where((w) => w.status != LearnStatus.completed)
                  .length;
              return Scaffold(
                body: Column(
                  children: [
                    Text('left $left'),
                    TextButton(
                      onPressed: () async {
                        await repo.upsertWord(Srs.discard(word, date));
                        invalidateData(ref);
                      },
                      child: const Text('discard'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('left 2'), findsOneWidget);

    await tester.tap(find.text('discard'));
    await tester.pumpAndSettle();
    expect(find.text('left 1'), findsOneWidget);
  });
}
