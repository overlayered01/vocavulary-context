import '../models/word.dart';

/// 복습할 때 같은 예문만 반복되지 않도록 예문 순서를 관리한다.
class ReviewExamples {
  const ReviewExamples._();

  /// 이전 학습 횟수를 기준으로 이번 복습에서 보여 줄 예문 인덱스를 고른다.
  ///
  /// 정답/오답 여부와 관계없이 문제를 한 번 풀 때마다 다음 예문으로 넘어가므로
  /// 앱을 다시 실행해도 순환 순서가 유지된다.
  static int initialIndex(Word word) {
    if (word.examples.isEmpty) return -1;
    return (word.timesCorrect + word.timesWrong) % word.examples.length;
  }

  /// 사용자가 복습 중 '다른 예문'을 누르면 다음 예문으로 순환한다.
  static int nextIndex(int current, int exampleCount) {
    if (exampleCount <= 0) return -1;
    return (current + 1) % exampleCount;
  }
}
