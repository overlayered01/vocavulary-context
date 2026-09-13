import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class DictionarySense {
  final String definition;
  final String partOfSpeech;
  final List<String> korean;
  final List<String> examples;
  final List<String> tags;
  final int depth;

  const DictionarySense({
    required this.definition,
    required this.partOfSpeech,
    this.korean = const [],
    this.examples = const [],
    this.tags = const [],
    this.depth = 0,
  });

  String get meaning => korean.isEmpty ? definition : korean.join(', ');

  String get partOfSpeechLabel =>
      const {
        'noun': '명사',
        'verb': '동사',
        'adjective': '형용사',
        'adverb': '부사',
        'pronoun': '대명사',
        'preposition': '전치사',
        'conjunction': '접속사',
        'interjection': '감탄사',
        'article': '관사',
        'determiner': '한정사',
        'phrase': '숙어',
      }[partOfSpeech] ??
      partOfSpeech;
}

class DictionaryResult {
  final String term;
  final List<DictionarySense> senses;
  final String phonetic;

  const DictionaryResult({
    required this.term,
    required this.senses,
    this.phonetic = '',
  });

  factory DictionaryResult.fromMap(String term, Map<String, dynamic> data) {
    final senses = <DictionarySense>[];
    final seen = <String>{};
    var phonetic = '';

    void readSenses(
      dynamic values,
      String partOfSpeech, [
      List<String> inheritedTags = const [],
      int depth = 0,
    ]) {
      if (values is! List) return;
      for (final raw in values.whereType<Map>()) {
        final definition = (raw['definition'] as String? ?? '').trim();
        final korean = <String>{};
        final tags = [
          ...inheritedTags,
          if (raw['tags'] is List) ...(raw['tags'] as List).whereType<String>(),
        ];
        final translations = raw['translations'];
        if (translations is List) {
          for (final translation in translations.whereType<Map>()) {
            final language = translation['language'];
            final word = translation['word'];
            if (language is Map &&
                const ['ko', 'kor'].contains(language['code']) &&
                word is String &&
                word.trim().isNotEmpty) {
              korean.add(word.trim());
            }
          }
        }
        if (definition.isNotEmpty && seen.add('$partOfSpeech\n$definition')) {
          senses.add(
            DictionarySense(
              definition: definition,
              partOfSpeech: partOfSpeech,
              korean: korean.toList(),
              tags: tags,
              depth: depth,
              examples: raw['examples'] is List
                  ? (raw['examples'] as List)
                        .whereType<String>()
                        .map((text) => text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList()
                  : const [],
            ),
          );
        }
        readSenses(raw['subsenses'], partOfSpeech, tags, depth + 1);
      }
    }

    final entries = data['entries'];
    if (entries is! List) throw const FormatException('Missing entries');
    for (final entry in entries.whereType<Map>()) {
      final language = entry['language'];
      if (language is! Map || !const ['en', 'eng'].contains(language['code'])) {
        continue;
      }
      final pronunciations = entry['pronunciations'];
      if (phonetic.isEmpty && pronunciations is List) {
        for (final pronunciation in pronunciations.whereType<Map>()) {
          final text = pronunciation['text'];
          if (pronunciation['type'] == 'ipa' &&
              text is String &&
              text.trim().isNotEmpty) {
            phonetic = text.trim();
            break;
          }
        }
      }
      readSenses(entry['senses'], entry['partOfSpeech'] as String? ?? '');
    }
    return DictionaryResult(
      term: term,
      senses: List.unmodifiable(senses),
      phonetic: phonetic,
    );
  }
}

class DictionaryLookupException implements Exception {
  final String message;
  const DictionaryLookupException(this.message);
}

/// English Wiktionary data, including Korean translations when available.
class DictionaryService {
  final http.Client _client;
  final _cache = <String, DictionaryResult>{};

  DictionaryService({http.Client? client}) : _client = client ?? http.Client();

  Future<DictionaryResult> lookup(String term) async {
    final query = term.trim();
    if (query.isEmpty) return DictionaryResult(term: query, senses: const []);
    final cached = _cache[query];
    if (cached != null) return cached;

    try {
      final uri = Uri(
        scheme: 'https',
        host: 'freedictionaryapi.com',
        pathSegments: ['api', 'v1', 'entries', 'en', query],
        queryParameters: {'translations': 'true'},
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 404) {
        return DictionaryResult(term: query, senses: const []);
      }
      if (response.statusCode == 429) {
        throw const DictionaryLookupException(
          '사전 조회가 잠시 제한됐어요. 잠시 후 다시 시도해 주세요.',
        );
      }
      if (response.statusCode != 200) {
        throw const DictionaryLookupException(
          '사전에 연결하지 못했어요. 잠시 후 다시 시도해 주세요.',
        );
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) throw const FormatException();
      final result = DictionaryResult.fromMap(query, data);
      if (_cache.length >= 50) _cache.remove(_cache.keys.first);
      _cache[query] = result;
      return result;
    } on DictionaryLookupException {
      rethrow;
    } on TimeoutException {
      throw const DictionaryLookupException('사전 응답이 늦어지고 있어요. 다시 시도해 주세요.');
    } catch (_) {
      throw const DictionaryLookupException(
        '사전 뜻을 불러오지 못했어요. 인터넷 연결을 확인하고 다시 시도해 주세요.',
      );
    }
  }

  void dispose() => _client.close();
}
