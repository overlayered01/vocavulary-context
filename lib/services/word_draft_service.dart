import '../models/translation_language.dart';
import '../models/word.dart';
import 'dictionary_service.dart';
import 'example_source_service.dart';
import 'offline_examples.dart';

/// 사전에서 찾은 한 품사의 뜻과 예문. 단어 카드 한 장은 품사 하나다.
class SenseGroup {
  /// 저장용 품사 값 (한국어 품사명, 예: '동사'). 모르면 빈 문자열.
  final String partOfSpeech;
  final List<String> meanings;

  /// 이 품사의 사전 예문. 번역이 있으면 함께 담긴다.
  final List<Example> examples;

  /// 뜻별 사전 출처 (Word.dictionarySourceTerms 형식).
  final Map<String, String> sourceTerms;

  /// 뜻이 번역 언어가 아니라 영어 풀이인지.
  final bool englishOnly;

  const SenseGroup({
    required this.partOfSpeech,
    required this.meanings,
    this.examples = const [],
    this.sourceTerms = const {},
    this.englishOnly = false,
  });
}

class WordLookup {
  final String term;
  final String phonetic;
  final List<SenseGroup> groups;

  /// 사전 연결에 실패했는지 (결과 없음과 구분).
  final bool failed;
  const WordLookup({
    required this.term,
    this.phonetic = '',
    this.groups = const [],
    this.failed = false,
  });
}

/// 단어 추가 화면의 사전 조회와 예문 후보를 만든다. 저장은 하지 않는다.
class WordDraftService {
  final DictionaryService dictionary;
  final ExampleSourceService examples;

  /// 품사를 미리 붙여 둔 내장 Tatoeba 예문. 없으면 온라인 예문만 쓴다.
  final OfflineExamples? offline;
  final TranslationLanguage translationLanguage;

  const WordDraftService({
    required this.dictionary,
    required this.examples,
    this.offline,
    this.translationLanguage = TranslationLanguage.korean,
  });

  static const _uncommon = {
    'archaic',
    'obsolete',
    'dated',
    'rare',
    'historical',
    'nonstandard',
    'slang',
    'offensive',
    'vulgar',
    'derogatory',
  };

  /// 뜻을 품사별로 묶는다. 번역 언어 풀이가 있는 품사는 번역만 쓰고,
  /// 번역이 하나도 없는 품사만 영어 풀이로 채운다.
  Future<WordLookup> lookup(String term) async {
    final query = term.trim();
    if (query.isEmpty) return WordLookup(term: query);
    DictionaryResult result;
    try {
      result = await dictionary.lookup(
        query,
        translationLanguage: translationLanguage,
        remoteTimeout: const Duration(seconds: 3),
      );
    } catch (_) {
      return WordLookup(term: query, failed: true);
    }
    final usual = result.senses
        .where((sense) => !sense.tags.any(_uncommon.contains))
        .toList();
    final senses = usual.isEmpty ? result.senses : usual;

    final order = <String>[];
    final byPart = <String, List<DictionarySense>>{};
    for (final sense in senses) {
      final part = sense.partOfSpeechLabel;
      if (!byPart.containsKey(part)) order.add(part);
      byPart.putIfAbsent(part, () => []).add(sense);
    }

    final groups = <SenseGroup>[];
    for (final part in order) {
      final all = byPart[part]!;
      final translated = all.where((s) => s.translations.isNotEmpty).toList();
      final useTranslated =
          translationLanguage.hasTranslations && translated.isNotEmpty;
      final pool = useTranslated ? translated : all;
      final ordered = [
        ...pool.where((s) => s.depth == 0),
        ...pool.where((s) => s.depth > 0),
      ];
      final meanings = <String>[];
      final sourceTerms = <String, String>{};
      for (final sense in ordered) {
        final meaning = sense.meaning.trim();
        if (meaning.isEmpty || meanings.contains(meaning)) continue;
        meanings.add(meaning);
        sourceTerms[meaning] = sense.sourceTerm(query);
        if (meanings.length == 6) break;
      }
      if (meanings.isEmpty) continue;
      groups.add(
        SenseGroup(
          partOfSpeech: part,
          meanings: meanings,
          examples: _dictionaryExamples(all, query),
          sourceTerms: sourceTerms,
          englishOnly: translationLanguage.hasTranslations && !useTranslated,
        ),
      );
    }
    return WordLookup(
      term: query,
      phonetic: result.phonetic,
      groups: groups,
    );
  }

  /// 같은 품사 뜻들에 붙은 사전 예문. 번역 있는 예문을 앞에 둔다.
  List<Example> _dictionaryExamples(List<DictionarySense> senses, String term) {
    final seen = <String>{};
    final found = <Example>[];
    for (final sense in senses) {
      for (final (index, sentence) in sense.examples.indexed) {
        final text = sentence.trim();
        // 'take prisoners' 같은 짧은 구절은 예문으로 쓰기 어렵다.
        if (text.split(RegExp(r'\s+')).length < 4) continue;
        if (!seen.add(text.toLowerCase())) continue;
        final translation = index < sense.exampleTranslations.length
            ? sense.exampleTranslations[index].trim()
            : '';
        found.add(
          Example(
            sentence: text,
            translation: translation,
            source: 'Wiktionary',
            sourceId: sense.sourceTerm(term),
            license: 'CC BY-SA 4.0',
          ),
        );
      }
    }
    found.sort(
      (a, b) => (a.translation.isEmpty ? 1 : 0).compareTo(
        b.translation.isEmpty ? 1 : 0,
      ),
    );
    return found.take(6).toList();
  }

  /// Tatoeba 예문 중 [partOfSpeech]로 쓰인 문장만 돌려준다. 사전 예문 다음 후보로 쓴다.
  ///
  /// 내장 예문은 빌드할 때 품사를 붙여 두어서 정확하다. 3개가 안 되거나
  /// 해석을 원하는데 해석 있는 문장이 없으면 온라인 Tatoeba에서 더 찾는다.
  /// 온라인 결과에는 품사 정보가 없어서 앞뒤 단어로 거른다.
  Future<List<Example>> tatoebaExamples(
    String term,
    String partOfSpeech, {
    bool withTranslations = true,
  }) async {
    final language = withTranslations && translationLanguage.hasTranslations
        ? translationLanguage
        : TranslationLanguage.english;
    final bundled =
        await offline?.find(
          term,
          partOfSpeech,
          translationLanguage: language,
        ) ??
        const <Example>[];
    final wantsTranslation = language.hasTranslations;
    if (bundled.length >= 3 &&
        (!wantsTranslation || bundled.any((e) => e.translation.isNotEmpty))) {
      return bundled;
    }
    List<Example> fetched;
    try {
      fetched = await examples.fetchExamples(
        term,
        limit: 8,
        translationLanguage: language,
      );
    } catch (_) {
      if (bundled.isNotEmpty) return bundled;
      rethrow;
    }
    final seen = {for (final e in bundled) e.sentence.toLowerCase()};
    final merged = [
      ...bundled,
      for (final example in fetched)
        if (matchesPartOfSpeech(example.sentence, term, partOfSpeech) &&
            seen.add(example.sentence.toLowerCase()))
          example,
    ];
    if (!wantsTranslation) return merged;
    // 해석이 있는 문장을 앞으로 (같은 조건에서는 내장 예문이 먼저).
    return [
      for (final e in merged)
        if (e.translation.isNotEmpty) e,
      for (final e in merged)
        if (e.translation.isEmpty) e,
    ];
  }

  static const _determiners = {
    'a',
    'an',
    'the',
    'my',
    'your',
    'his',
    'her',
    'its',
    'our',
    'their',
    'this',
    'that',
    'these',
    'those',
    'some',
    'any',
    'no',
    'every',
    'each',
  };
  static const _verbSignals = {
    'to',
    'i',
    'you',
    'he',
    'she',
    'we',
    'they',
    'will',
    'would',
    'can',
    'could',
    'should',
    'must',
    'may',
    'might',
    'do',
    'does',
    'did',
    "don't",
    "doesn't",
    "didn't",
    "won't",
    "can't",
    'not',
  };

  /// 문장 속 단어가 [partOfSpeech]로 쓰였는지 가볍게 추정한다.
  /// 판단할 수 없으면 true.
  static bool matchesPartOfSpeech(
    String sentence,
    String term,
    String partOfSpeech,
  ) {
    final match = RegExp(
      '\\b${RegExp.escape(term.trim())}\\w*',
      caseSensitive: false,
    ).firstMatch(sentence);
    if (match == null) return true;
    final before = sentence.substring(0, match.start).trim().split(
      RegExp(r'\s+'),
    );
    String word(int fromEnd) => before.length < fromEnd || before.first.isEmpty
        ? ''
        : before[before.length - fromEnd].toLowerCase().replaceAll(
            RegExp(r'[^a-z\x27]'),
            '',
          );
    final previous = word(1);
    switch (partOfSpeech) {
      case '동사':
        // 'a run', 'a good run'처럼 한정사 뒤(형용사 하나 건너)는 명사로 본다.
        return !_determiners.contains(previous) &&
            !_determiners.contains(word(2)) &&
            !previous.endsWith("'s");
      case '명사':
        return !_verbSignals.contains(previous);
      default:
        return true;
    }
  }

  /// 저장할 카드. 같은 단어라도 품사가 다르면 다른 카드다.
  Word buildWord({
    required String wordbookId,
    required String term,
    required String partOfSpeech,
    required List<String> meanings,
    required List<Example> examples,
    String phonetic = '',
    Iterable<String> sourceTerms = const [],
    bool withTranslations = true,
  }) {
    final now = DateTime.now();
    return Word(
      id: '',
      wordbookId: wordbookId,
      term: term.trim(),
      translationLanguage: translationLanguage.code,
      meanings: Word.normalizeMeanings(meanings),
      dictionarySourceTerms: {...sourceTerms}.toList(),
      partOfSpeech: partOfSpeech,
      phonetic: phonetic,
      examples: [
        for (final e in examples)
          withTranslations
              ? e
              : Example(
                  sentence: e.sentence,
                  source: e.source,
                  sourceId: e.sourceId,
                  license: e.license,
                ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }
}
