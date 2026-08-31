import 'package:flutter_test/flutter_test.dart';

import 'package:vocabulary/data/srs.dart';
import 'package:vocabulary/models/word.dart';

void main() {
  group('Srs', () {
    Word makeWord({LearnStatus status = LearnStatus.fresh}) {
      final now = DateTime(2026, 1, 1);
      return Word(
        id: 'w1',
        wordbookId: 'b1',
        term: 'crucial',
        meaning: '중대한',
        status: status,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('정답 처리 시 단계가 오른다', () {
      final w = makeWord();
      final updated = Srs.applyCorrect(w, DateTime(2026, 1, 1));
      expect(updated.srsStage, 1);
      expect(updated.timesCorrect, 1);
    });

    test('오답 처리 시 단계가 0으로 초기화된다', () {
      final w = makeWord().copyWith(srsStage: 3);
      final updated = Srs.applyWrong(w, DateTime(2026, 1, 1));
      expect(updated.srsStage, 0);
      expect(updated.timesWrong, 1);
    });

    test('채점은 공백/대소문자를 무시한다', () {
      expect(Srs.checkAnswer('  Crucial ', 'crucial'), isTrue);
      expect(Srs.checkAnswer('wrong', 'crucial'), isFalse);
    });

    test('복습 섞기 비율만큼 완료 단어가 포함된다', () {
      final now = DateTime(2026, 1, 1);
      final due = List.generate(
        20,
        (i) => Word(
          id: 'due$i',
          wordbookId: 'b1',
          term: 'word$i',
          meaning: 'm',
          status: LearnStatus.fresh,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final done = List.generate(
        10,
        (i) => Word(
          id: 'done$i',
          wordbookId: 'b1',
          term: 'done$i',
          meaning: 'm',
          status: LearnStatus.completed,
          completedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final session = Srs.buildSession(
        [...due, ...done],
        now,
        mixRatio: 20,
        sessionSize: 15,
      );
      final mixed = session
          .where((w) => w.status == LearnStatus.completed)
          .length;
      expect(session.length, 15);
      expect(mixed, 3); // 15 * 20% = 3
    });
  });

  test('단어 대표 이미지를 직렬화하고 복원한다', () {
    final now = DateTime(2026, 1, 1);
    final word = Word(
      id: 'image-word',
      wordbookId: 'b1',
      term: 'apple',
      meaning: '사과',
      imageUrl: 'data:image/png;base64,dGVzdA==',
      createdAt: now,
      updatedAt: now,
    );

    final restored = Word.fromMap(word.toMap());

    expect(restored.imageUrl, word.imageUrl);
  });
}
