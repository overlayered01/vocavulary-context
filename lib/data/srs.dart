import 'dart:math';
import '../models/word.dart';

/// 간격 반복(SRS) 및 복습 세션 구성 로직.
class Srs {
  /// SRS 단계별 복습 간격(일). 마지막 단계 도달 시 'completed' 처리.
  static const intervalsDays = [1, 3, 7, 30];

  /// 정답 처리: 다음 단계로 올리고 다음 복습 시각을 계산.
  static Word applyCorrect(Word w, DateTime now) {
    final nextStage = min(w.srsStage + 1, intervalsDays.length);
    final reachedEnd = nextStage >= intervalsDays.length;
    final intervalDays =
        intervalsDays[min(nextStage, intervalsDays.length - 1)];
    return w.copyWith(
      srsStage: nextStage,
      status: reachedEnd ? LearnStatus.completed : LearnStatus.learning,
      completedAt: reachedEnd ? (w.completedAt ?? now) : w.completedAt,
      nextReviewAt: now.add(Duration(days: intervalDays)),
      timesCorrect: w.timesCorrect + 1,
      updatedAt: now,
    );
  }

  /// 오답 처리: 단계를 0으로 되돌리고 곧 다시 복습하도록 예약.
  static Word applyWrong(Word w, DateTime now) {
    return w.copyWith(
      srsStage: 0,
      status: LearnStatus.learning,
      nextReviewAt: now.add(const Duration(minutes: 10)),
      timesWrong: w.timesWrong + 1,
      updatedAt: now,
    );
  }

  /// 복습 대상 여부: 신규이거나, 복습 예정 시각이 지났으면 true.
  static bool isDue(Word w, DateTime now) {
    if (w.status == LearnStatus.completed) return false;
    if (w.nextReviewAt == null) return true; // 아직 학습 안 함
    return !w.nextReviewAt!.isAfter(now);
  }

  /// 복습 세션을 구성한다.
  ///
  /// - 기본은 복습 도래(due) 단어로 채운다.
  /// - [mixRatio](0~100)만큼 '완료(completed)' 단어를 섞어 장기 기억을 강화한다.
  ///   완료된 지 오래되고 정답률이 낮은 단어를 우선 선택한다.
  /// - [sessionSize]는 한 세션 최대 문항 수.
  static List<Word> buildSession(
    List<Word> all,
    DateTime now, {
    int mixRatio = 0,
    int sessionSize = 15,
  }) {
    final due = all.where((w) => isDue(w, now)).toList()
      ..sort((a, b) {
        final an = a.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bn = b.nextReviewAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return an.compareTo(bn);
      });

    final mixCount = (sessionSize * mixRatio / 100).round();
    final dueCount = (sessionSize - mixCount).clamp(0, sessionSize);

    final session = <Word>[...due.take(dueCount)];

    if (mixCount > 0) {
      final completed =
          all.where((w) => w.status == LearnStatus.completed).toList()
            // 오래 전 완료 + 오답 많은 순으로 우선.
            ..sort((a, b) {
              final ac =
                  a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bc =
                  b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final byDate = ac.compareTo(bc); // 오래된 것 먼저
              if (byDate != 0) return byDate;
              return b.timesWrong.compareTo(a.timesWrong); // 오답 많은 것 먼저
            });
      session.addAll(completed.take(mixCount));
    }

    // due가 부족하면 남는 자리를 완료 단어로 추가로 채움.
    if (session.length < sessionSize) {
      final used = session.map((w) => w.id).toSet();
      final extra = all
          .where(
            (w) => w.status == LearnStatus.completed && !used.contains(w.id),
          )
          .take(sessionSize - session.length);
      session.addAll(extra);
    }

    return session;
  }

  /// 입력 채점: 공백/대소문자 무시, 양끝 공백 제거 후 비교.
  static bool checkAnswer(String input, String term) {
    String norm(String s) =>
        s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return norm(input) == norm(term);
  }
}
