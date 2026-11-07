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

  test('여러 단어로 된 말·둥근 아포스트로피·악센트 글자도 찾는다', () {
    // 한 단어는 예전처럼 활용형을 찾는다.
    expect(sentencesWithTerm('The dogs played outside.', 'play'), [
      'The dogs played outside.',
    ]);
    expect(
      sentencesWithTerm('He likes to read. I will never give up.', 'give up'),
      ['I will never give up.'],
    );
    expect(sentencesWithTerm('She gave up on the plan.', 'give up'), [
      'She gave up on the plan.',
    ]);
    expect(sentencesWithTerm('Give me the cup.', 'give up'), isEmpty);
    expect(
      sentencesWithTerm('We are looking forward to it.', 'look forward to'),
      ['We are looking forward to it.'],
    );
    expect(sentencesWithTerm('I don’t know why.', "don't"), [
      'I don’t know why.',
    ]);
    // 둥근 아포스트로피로 단어가 쪼개지지 않는다(don + t).
    expect(sentencesWithTerm('I don’t know why.', 't'), isEmpty);
    expect(sentencesWithTerm('We met at a small café today.', 'café'), [
      'We met at a small café today.',
    ]);
    expect(sentencesWithTerm('We met at a small café today.', 'Café'), [
      'We met at a small café today.',
    ]);
  });

  test('예문 문제는 예문 있는 카드만, 시작·뜻 문제는 모든 카드', () {
    expect(ReviewMode.input.examplesOnly, isTrue);
    expect(ReviewMode.choice.examplesOnly, isTrue);
    expect(ReviewMode.meaning.examplesOnly, isFalse);
    expect(ReviewMode.mixed.examplesOnly, isFalse);
    // 시작·뜻 문제는 설정을 따르고, 기본은 빈칸에 직접 쓰기.
    expect(ReviewMode.input.usesChoices(answerByChoice: true), isFalse);
    expect(ReviewMode.choice.usesChoices(), isTrue);
    expect(ReviewMode.mixed.usesChoices(), isFalse);
    expect(ReviewMode.mixed.usesChoices(answerByChoice: true), isTrue);
    expect(ReviewMode.meaning.usesChoices(answerByChoice: true), isTrue);
  });
}
