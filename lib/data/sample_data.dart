import '../models/word.dart';
import '../models/wordbook.dart';

/// 첫 실행 시 시드되는 예시 단어장. 예문 복습을 바로 체험할 수 있게 한다.
(Wordbook, List<Word>) buildSampleData(
  String Function() newBookId,
  String Function() newWordId,
) {
  final now = DateTime.now();
  final bookId = newBookId();

  final wb = Wordbook(
    id: bookId,
    ownerId: 'local',
    title: '토익 필수 단어',
    description: '예문으로 익히는 기본 단어장',
    tags: const ['토익', '기본'],
    groups: const ['Day 1', 'Day 2'],
    createdAt: now,
    updatedAt: now,
  );

  Word make(
    String term,
    String meaning,
    String pos,
    String phonetic,
    String group,
    List<Example> ex,
  ) {
    return Word(
      id: newWordId(),
      wordbookId: bookId,
      group: group,
      term: term,
      meaning: meaning,
      partOfSpeech: pos,
      phonetic: phonetic,
      examples: ex,
      createdAt: now,
      updatedAt: now,
    );
  }

  final words = <Word>[
    make('crucial', '중대한, 결정적인', '형용사', '/ˈkruːʃl/', 'Day 1', const [
      Example(
        sentence: 'This is a crucial decision that will affect everyone.',
        translation: '이것은 모두에게 영향을 줄 중대한 결정이다.',
      ),
      Example(
        sentence: 'Water is crucial for life.',
        translation: '물은 생명에 필수적이다.',
      ),
    ]),
    make('benefit', '이익, 혜택', '명사', '/ˈbenɪfɪt/', 'Day 1', const [
      Example(
        sentence: 'Regular exercise has many health benefits.',
        translation: '규칙적인 운동은 많은 건강상의 이점이 있다.',
      ),
    ]),
    make('abandon', '버리다, 포기하다', '동사', '/əˈbændən/', 'Day 2', const [
      Example(
        sentence: 'They had to abandon the project due to lack of funds.',
        translation: '그들은 자금 부족으로 프로젝트를 포기해야 했다.',
      ),
    ]),
    make('significant', '중요한, 상당한', '형용사', '/sɪɡˈnɪfɪkənt/', 'Day 2', const [
      Example(
        sentence: 'There was a significant increase in sales.',
        translation: '매출에 상당한 증가가 있었다.',
      ),
    ]),
    make('approach', '접근하다; 접근법', '동사/명사', '/əˈproʊtʃ/', '', const [
      Example(
        sentence: 'We need a new approach to solve this problem.',
        translation: '이 문제를 해결하려면 새로운 접근법이 필요하다.',
      ),
    ]),
  ];

  return (wb, words);
}
