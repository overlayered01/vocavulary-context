import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary/services/sentence_extractor.dart';
import 'package:vocabulary/screens/review_screen.dart';

void main() {
  test('사진 글에서 줄바꿈·하이픈을 이어 붙이고 단어가 든 문장만 고른다', () {
    const text = '''Chapter 2
The company will charge a small fee. Nobody knew
why the price had been raised. They were char-
ged twice for the same order! She
ran to the station.''';
    expect(sentencesWithTerm(text, 'charge'), [
      'The company will charge a small fee.',
      'They were charged twice for the same order!',
    ]);
    // 불규칙 활용(ran → run)도 찾는다.
    expect(sentencesWithTerm(text, 'run'), ['She ran to the station.']);
    expect(sentencesWithTerm(text, 'abandon'), isEmpty);
  });

  test('예문 문제는 예문 있는 카드만, 시작·뜻 문제는 모든 카드', () {
    expect(ReviewMode.input.examplesOnly, isTrue);
    expect(ReviewMode.choice.examplesOnly, isTrue);
    expect(ReviewMode.meaning.examplesOnly, isFalse);
    expect(ReviewMode.mixed.examplesOnly, isFalse);
    expect(ReviewMode.input.usesChoices, isFalse);
    expect(ReviewMode.meaning.usesChoices, isTrue);
  });
}
