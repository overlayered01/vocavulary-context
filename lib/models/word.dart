/// 단어 학습 상태 (예문 복습 + SRS).
enum LearnStatus { fresh, learning, completed }

/// 예문 한 개 (영어 문장 + 한글 해석).
class Example {
  final String sentence;
  final String translation;

  const Example({required this.sentence, this.translation = ''});

  Map<String, dynamic> toMap() => {
    'sentence': sentence,
    'translation': translation,
  };

  factory Example.fromMap(Map<String, dynamic> m) => Example(
    sentence: (m['sentence'] ?? '') as String,
    translation: (m['translation'] ?? '') as String,
  );
}

/// 단어. 예문·발음 정보와 SRS(간격 반복) 학습 상태를 함께 가진다.
class Word {
  final String id;
  final String wordbookId;

  /// 단어장 내 소분류 그룹명. 빈 문자열이면 '그룹 없음'.
  final String group;
  final String term;
  final String meaning;
  final String partOfSpeech;
  final String phonetic;

  /// 대표 이미지. 웹/로컬에서는 data URL, 클라우드에서는 HTTPS URL도 허용한다.
  final String imageUrl;
  final List<Example> examples;
  final bool favorite;

  // --- SRS / 복습 상태 ---
  final LearnStatus status;

  /// SRS 단계: 0,1,2,3 ... (간격 1·3·7·30일에 매핑)
  final int srsStage;

  /// 다음 복습 예정 시각.
  final DateTime? nextReviewAt;

  /// 처음으로 '완료(completed)'가 된 시각. 복습 섞기 우선순위에 사용.
  final DateTime? completedAt;

  final int timesCorrect;
  final int timesWrong;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Word({
    required this.id,
    required this.wordbookId,
    this.group = '',
    required this.term,
    required this.meaning,
    this.partOfSpeech = '',
    this.phonetic = '',
    this.imageUrl = '',
    this.examples = const [],
    this.favorite = false,
    this.status = LearnStatus.fresh,
    this.srsStage = 0,
    this.nextReviewAt,
    this.completedAt,
    this.timesCorrect = 0,
    this.timesWrong = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 첫 글자 + 글자 수 힌트 (예: "c r _ _ _ _ _").
  String get inputHint {
    if (term.isEmpty) return '';
    final chars = term.split('').asMap().entries.map((e) {
      if (e.key == 0) return term[0];
      return term[e.key] == ' ' ? '/' : '_';
    });
    return chars.join(' ');
  }

  Word copyWith({
    String? group,
    String? term,
    String? meaning,
    String? partOfSpeech,
    String? phonetic,
    String? imageUrl,
    List<Example>? examples,
    bool? favorite,
    LearnStatus? status,
    int? srsStage,
    DateTime? nextReviewAt,
    DateTime? completedAt,
    int? timesCorrect,
    int? timesWrong,
    DateTime? updatedAt,
  }) {
    return Word(
      id: id,
      wordbookId: wordbookId,
      group: group ?? this.group,
      term: term ?? this.term,
      meaning: meaning ?? this.meaning,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      phonetic: phonetic ?? this.phonetic,
      imageUrl: imageUrl ?? this.imageUrl,
      examples: examples ?? this.examples,
      favorite: favorite ?? this.favorite,
      status: status ?? this.status,
      srsStage: srsStage ?? this.srsStage,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      completedAt: completedAt ?? this.completedAt,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesWrong: timesWrong ?? this.timesWrong,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'wordbookId': wordbookId,
    'group': group,
    'term': term,
    'meaning': meaning,
    'partOfSpeech': partOfSpeech,
    'phonetic': phonetic,
    'imageUrl': imageUrl,
    'examples': examples.map((e) => e.toMap()).toList(),
    'favorite': favorite,
    'status': status.name,
    'srsStage': srsStage,
    'nextReviewAt': nextReviewAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'timesCorrect': timesCorrect,
    'timesWrong': timesWrong,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Word.fromMap(Map<String, dynamic> m) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Word(
      id: m['id'] as String,
      wordbookId: (m['wordbookId'] ?? '') as String,
      group: (m['group'] ?? '') as String,
      term: (m['term'] ?? '') as String,
      meaning: (m['meaning'] ?? '') as String,
      partOfSpeech: (m['partOfSpeech'] ?? '') as String,
      phonetic: (m['phonetic'] ?? '') as String,
      imageUrl: (m['imageUrl'] ?? m['image'] ?? '') as String,
      examples: ((m['examples'] as List?) ?? [])
          .map((e) => Example.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      favorite: (m['favorite'] ?? false) as bool,
      status: LearnStatus.values.firstWhere(
        (s) => s.name == m['status'],
        orElse: () => LearnStatus.fresh,
      ),
      srsStage: (m['srsStage'] ?? 0) as int,
      nextReviewAt: parseDate(m['nextReviewAt']),
      completedAt: parseDate(m['completedAt']),
      timesCorrect: (m['timesCorrect'] ?? 0) as int,
      timesWrong: (m['timesWrong'] ?? 0) as int,
      createdAt: parseDate(m['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(m['updatedAt']) ?? DateTime.now(),
    );
  }
}
