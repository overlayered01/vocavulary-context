/// 학습 기록 한 건 (복습에서 문제 하나를 푼 결과).
/// 홈의 '오늘 학습' 통계 등 일일 집계에 사용한다.
class StudyLog {
  final String id;
  final String wordId;
  final bool correct;
  final DateTime studiedAt;

  const StudyLog({
    required this.id,
    required this.wordId,
    required this.correct,
    required this.studiedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'wordId': wordId,
    'correct': correct,
    'studiedAt': studiedAt.toIso8601String(),
  };

  factory StudyLog.fromMap(Map<String, dynamic> m) => StudyLog(
    id: (m['id'] ?? '') as String,
    wordId: (m['wordId'] ?? '') as String,
    correct: (m['correct'] ?? false) as bool,
    studiedAt:
        DateTime.tryParse(m['studiedAt']?.toString() ?? '') ?? DateTime.now(),
  );
}
