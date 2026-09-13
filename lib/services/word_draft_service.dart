import '../models/word.dart';
import 'dictionary_service.dart';
import 'example_source_service.dart';

class WordDraft {
  final Word word;
  final String notice;
  final Future<List<Example>>? pendingExamples;
  const WordDraft({
    required this.word,
    required this.notice,
    this.pendingExamples,
  });
}

/// Builds an editable draft; never writes to the repository.
class WordDraftService {
  final DictionaryService dictionary;
  final ExampleSourceService examples;
  const WordDraftService({required this.dictionary, required this.examples});

  Future<WordDraft> create({
    required String term,
    required String wordbookId,
    required List<Word> savedWords,
  }) async {
    final query = term.trim();
    if (query.isEmpty) throw ArgumentError.value(term, 'term');
    final matches =
        savedWords
            .where(
              (word) => word.term.trim().toLowerCase() == query.toLowerCase(),
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final saved = matches.firstOrNull;
    final needsDictionary =
        saved == null ||
        saved.meanings.isEmpty ||
        saved.partOfSpeech.isEmpty ||
        saved.phonetic.isEmpty;
    final needsExamples = (saved?.examples.length ?? 0) < 2;
    DictionaryResult? result;
    var fetchedExamples = const <Example>[];
    var dictionaryFailed = false;
    var examplesFailed = false;
    var examplesReady = !needsExamples;

    // Fetch both sources concurrently, but never hold up the draft for Tatoeba.
    final exampleRequest = () async {
      if (needsExamples) {
        try {
          fetchedExamples = await examples
              .fetchExamples(query, limit: 2)
              .timeout(const Duration(seconds: 12));
        } catch (_) {
          examplesFailed = true;
        }
      }
      examplesReady = true;
      return fetchedExamples;
    }();
    if (needsDictionary) {
      try {
        result = await dictionary.lookup(query);
      } catch (_) {
        dictionaryFailed = true;
      }
    }

    const uncommon = {
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
    final available = result?.senses ?? const <DictionarySense>[];
    final usual = available
        .where((sense) => !sense.tags.any(uncommon.contains))
        .toList();
    final eligible = usual.isEmpty ? available : usual;
    // Prefer separate main senses before filling in closely related subsenses.
    final candidates = [
      ...eligible.where((sense) => sense.depth == 0),
      ...eligible.where((sense) => sense.depth > 0),
    ];
    // One part-of-speech field applies to the whole word in the current model.
    final savedPart = saved?.partOfSpeech ?? '';
    final preferredPart = savedPart.isNotEmpty
        ? savedPart
        : (candidates.firstOrNull?.partOfSpeechLabel ?? '');
    final selected = <DictionarySense>[];
    final seenMeanings = <String>{};
    for (final sense in candidates) {
      if (sense.partOfSpeechLabel == preferredPart &&
          seenMeanings.add(sense.meaning)) {
        selected.add(sense);
        if (selected.length == 3) break;
      }
    }
    final usesDictionaryMeanings =
        (saved?.meanings.isEmpty ?? true) && selected.isNotEmpty;
    final meanings = usesDictionaryMeanings
        ? selected.map((sense) => sense.meaning).toList()
        : (saved?.meanings ?? const <String>[]);
    final phonetic = (saved?.phonetic.isNotEmpty ?? false)
        ? saved!.phonetic
        : (result?.phonetic ?? '');

    final dictionaryExamples = [
      for (final sense in selected)
        for (final sentence in sense.examples)
          Example(
            sentence: sentence,
            source: 'Wiktionary',
            sourceId: query,
            license: 'CC BY-SA 4.0',
          ),
    ];
    List<Example> combineExamples(List<Example> fetched) {
      final combined = [...?saved?.examples];
      final exampleTexts = combined
          .map((e) => e.sentence.trim().toLowerCase())
          .toSet();
      for (final example in [
        ...fetched.where((e) => e.translation.isNotEmpty),
        ...dictionaryExamples,
        ...fetched.where((e) => e.translation.isEmpty),
      ]) {
        if (combined.length >= 2) break;
        if (exampleTexts.add(example.sentence.trim().toLowerCase())) {
          combined.add(example);
        }
      }
      return combined;
    }

    final draftExamples = combineExamples(fetchedExamples);
    final sourceTerms = {...?saved?.dictionarySourceTerms};
    if (usesDictionaryMeanings ||
        ((saved?.phonetic.isEmpty ?? true) && phonetic.isNotEmpty) ||
        draftExamples.any(
          (e) => e.source == 'Wiktionary' && e.sourceId == query,
        )) {
      sourceTerms.add(query);
    }

    final notices = <String>[];
    if (meanings.isEmpty) {
      notices.add(
        dictionaryFailed
            ? '사전에 연결하지 못했어요. 뜻을 직접 입력하거나 다시 조회해 주세요.'
            : '뜻을 찾지 못했어요. 직접 입력하거나 사전에서 찾아보세요.',
      );
    } else if (usesDictionaryMeanings &&
        selected.every((s) => s.korean.isEmpty)) {
      notices.add('한국어 뜻이 없어 영어 풀이로 채웠어요.');
    }
    if (draftExamples.isEmpty && examplesFailed) {
      notices.add('예문은 아래의 ‘예문 가져오기’로 다시 불러올 수 있어요.');
    }
    final now = DateTime.now();
    return WordDraft(
      word: Word(
        id: '',
        wordbookId: wordbookId,
        term: query,
        meanings: meanings,
        dictionarySourceTerms: sourceTerms.toList(),
        partOfSpeech: savedPart.isNotEmpty
            ? savedPart
            : (selected.firstOrNull?.partOfSpeechLabel ?? ''),
        phonetic: phonetic,
        examples: draftExamples,
        imageUrl: saved?.imageUrl ?? '',
        createdAt: now,
        updatedAt: now,
      ),
      notice: notices.isEmpty ? '자동으로 채웠어요. 확인한 뒤 저장해 주세요.' : notices.join(' '),
      pendingExamples: examplesReady
          ? null
          : exampleRequest.then(combineExamples),
    );
  }
}
