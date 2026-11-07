import '../l10n/l10n.dart';
import '../models/word.dart';
import '../models/wordbook.dart';

/// 첫 실행 시 시드되는 기본 단어장. welcome 한 단어로 예문 복습을 바로 체험한다.
/// 뜻과 해석은 [l10n](번역 언어)으로 쓴다.
(Wordbook, List<Word>) buildSampleData(
  String Function() newBookId,
  String Function() newWordId, {
  required AppLocalizations l10n,
  required String translationLanguage,
}) {
  final now = DateTime.now();
  final bookId = newBookId();

  final wb = Wordbook(
    id: bookId,
    ownerId: 'local',
    title: 'Default',
    createdAt: now,
    updatedAt: now,
  );

  final words = <Word>[
    Word(
      id: newWordId(),
      wordbookId: bookId,
      term: 'welcome',
      translationLanguage: translationLanguage,
      meaning: l10n.sampleWelcomeMeaning,
      partOfSpeech: '감탄사',
      phonetic: '/ˈwelkəm/',
      examples: [
        Example(
          sentence: 'Welcome to Vocab with Examples!',
          translation: l10n.sampleWelcomeExample1,
        ),
        Example(
          sentence: 'Welcome back, everyone.',
          translation: l10n.sampleWelcomeExample2,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return (wb, words);
}
