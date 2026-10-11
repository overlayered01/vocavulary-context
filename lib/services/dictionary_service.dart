import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart' show Locale;
import 'package:http/http.dart' as http;

import '../l10n/l10n.dart';
import '../models/translation_language.dart';
import 'local_dictionary.dart';

class DictionarySense {
  final String definition;
  final String partOfSpeech;
  final List<String> translations;
  final List<String> examples;

  /// [examples]와 같은 순서의 번역. 없으면 비어 있거나 빈 문자열.
  final List<String> exampleTranslations;
  final List<String> tags;
  final int depth;

  /// 내장 언어판 사전에서 왔으면 그 Wiktionary 언어 코드(예: 'ko'), 온라인 사전이면 ''.
  final String source;

  /// 실제로 찾은 표제어. 활용형을 기본형으로 찾은 경우 기본형이다.
  final String headword;

  const DictionarySense({
    required this.definition,
    required this.partOfSpeech,
    this.translations = const [],
    this.examples = const [],
    this.exampleTranslations = const [],
    this.tags = const [],
    this.depth = 0,
    this.source = '',
    this.headword = '',
  });

  /// Word.dictionarySourceTerms에 남길 출처. 언어판 사전은 'ko:take' 형식이다.
  String sourceTerm(String query) =>
      source.isEmpty ? query : '$source:${headword.isEmpty ? query : headword}';

  String get meaning =>
      translations.isEmpty ? definition : translations.join(', ');

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

  factory DictionaryResult.fromMap(
    String term,
    Map<String, dynamic> data, {
    TranslationLanguage translationLanguage = TranslationLanguage.korean,
  }) {
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
        final translatedWords = <String>{};
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
                translationLanguage.matchesCode(language['code']) &&
                word is String &&
                word.trim().isNotEmpty) {
              translatedWords.add(word.trim());
            }
          }
        }
        if (definition.isNotEmpty && seen.add('$partOfSpeech\n$definition')) {
          senses.add(
            DictionarySense(
              definition: definition,
              partOfSpeech: partOfSpeech,
              translations: translatedWords.toList(),
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

/// English Wiktionary data with translations in the selected language.
class DictionaryService {
  final http.Client _client;
  final _cache = <(String, TranslationLanguage), DictionaryResult>{};

  final AppLocalizations _l10n;

  /// 앱에 내장한 언어판 사전. 있으면 그 풀이를 온라인 결과보다 앞에 둔다.
  final LocalDictionary? local;

  DictionaryService({http.Client? client, AppLocalizations? l10n, this.local})
    : _client = client ?? http.Client(),
      _l10n = l10n ?? lookupAppLocalizations(const Locale('ko'));

  /// 내장 사전 풀이를 먼저, 온라인 사전 풀이를 뒤에 합쳐 돌려준다.
  ///
  /// 내장 사전에서 찾았으면 온라인 사전은 [remoteTimeout]까지만 기다리고,
  /// 실패하거나 늦으면 내장 사전 결과만 쓴다(발음기호는 온라인 결과에서만 온다).
  Future<DictionaryResult> lookup(
    String term, {
    TranslationLanguage translationLanguage = TranslationLanguage.korean,
    Duration remoteTimeout = const Duration(seconds: 15),
  }) async {
    final query = term.trim();
    final entries = query.isEmpty || local == null
        ? const <LocalDictionaryEntry>[]
        : await local!.lookup(query, translationLanguage);
    if (entries.isEmpty) {
      return _lookupRemote(query, translationLanguage);
    }
    DictionaryResult? remote;
    try {
      remote = await _lookupRemote(
        query,
        translationLanguage,
      ).timeout(remoteTimeout);
    } catch (_) {
      // 내장 사전 결과만으로도 뜻을 채울 수 있다.
    }
    final senses = <DictionarySense>[
      for (final entry in entries)
        for (final (index, gloss) in entry.glosses.indexed)
          DictionarySense(
            definition: '',
            partOfSpeech: entry.partOfSpeech,
            translations: [gloss],
            source: translationLanguage.code,
            headword: entry.headword,
            // 사전 예문은 품사 단위로 붙어 있어 그 품사의 첫 뜻에만 단다.
            examples: index == 0
                ? [for (final (text, _) in entry.examples) text]
                : const [],
            exampleTranslations: index == 0
                ? [for (final (_, translation) in entry.examples) translation]
                : const [],
          ),
    ];
    final seen = {for (final sense in senses) sense.meaning};
    return DictionaryResult(
      term: query,
      senses: [
        ...senses,
        ...?remote?.senses.where((sense) => seen.add(sense.meaning)),
      ],
      phonetic: remote?.phonetic ?? '',
    );
  }

  Future<DictionaryResult> _lookupRemote(
    String query,
    TranslationLanguage translationLanguage,
  ) async {
    if (query.isEmpty) return DictionaryResult(term: query, senses: const []);
    final key = (query, translationLanguage);
    final cached = _cache[key];
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
        throw DictionaryLookupException(_l10n.dictionaryRateLimited);
      }
      if (response.statusCode != 200) {
        throw DictionaryLookupException(_l10n.dictionaryConnectionFailed);
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) throw const FormatException();
      final result = DictionaryResult.fromMap(
        query,
        data,
        translationLanguage: translationLanguage,
      );
      if (_cache.length >= 50) _cache.remove(_cache.keys.first);
      _cache[key] = result;
      return result;
    } on DictionaryLookupException {
      rethrow;
    } on TimeoutException {
      throw DictionaryLookupException(_l10n.dictionaryTimeout);
    } catch (_) {
      throw DictionaryLookupException(_l10n.dictionaryLoadFailed);
    }
  }

  void dispose() => _client.close();
}
