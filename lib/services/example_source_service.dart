import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/word.dart';
import '../models/translation_language.dart';

/// Tatoeba의 공개 API에서 영어 예문과 선택한 언어의 번역을 가져온다.
class ExampleSourceService {
  final http.Client _client;
  final _cache =
      <
        (String, int, TranslationLanguage),
        ({List<Example> values, DateTime expires})
      >{};
  final _pending =
      <(String, int, TranslationLanguage), Future<List<Example>>>{};

  ExampleSourceService({http.Client? client})
    : _client = client ?? http.Client();

  static const _host = 'api.tatoeba.org';
  static const _path = '/v1/sentences';

  Future<List<Example>> fetchExamples(
    String term, {
    int limit = 6,
    TranslationLanguage translationLanguage = TranslationLanguage.korean,
  }) async {
    final query = term.trim();
    if (query.isEmpty) return const [];
    final key = (query, limit, translationLanguage);
    final cached = _cache[key];
    if (cached != null && cached.expires.isAfter(DateTime.now())) {
      return cached.values;
    }
    final inFlight = _pending[key];
    if (inFlight != null) return inFlight;
    final request = _loadExamples(
      query,
      limit: limit,
      translationLanguage: translationLanguage,
    );
    _pending[key] = request;
    try {
      final values = List<Example>.unmodifiable(await request);
      if (values.isNotEmpty) {
        if (_cache.length >= 50) _cache.remove(_cache.keys.first);
        _cache[key] = (
          values: values,
          expires: DateTime.now().add(const Duration(minutes: 10)),
        );
      }
      return values;
    } finally {
      _pending.remove(key);
    }
  }

  Future<List<Example>> _loadExamples(
    String term, {
    required int limit,
    required TranslationLanguage translationLanguage,
  }) async {
    final normalized = term.trim();
    if (normalized.isEmpty) return const [];

    // 영어(해석 없음)는 원문만 가져온다.
    if (!translationLanguage.hasTranslations) {
      return _fetch(
        normalized,
        limit: limit,
        requireTranslation: false,
        translationLanguage: translationLanguage,
      );
    }

    // 선택 언어의 직접 번역이 있는 예문을 우선하고 부족하면 원문으로 채운다.
    final translated = await _fetch(
      normalized,
      limit: limit,
      requireTranslation: true,
      translationLanguage: translationLanguage,
    );
    if (translated.length >= limit) return translated.take(limit).toList();

    final List<Example> english;
    try {
      english = await _fetch(
        normalized,
        limit: limit,
        requireTranslation: false,
        translationLanguage: translationLanguage,
      );
    } catch (_) {
      if (translated.isNotEmpty) return translated;
      rethrow;
    }
    final unique = <String, Example>{
      for (final example in translated) example.sentence.toLowerCase(): example,
    };
    for (final example in english) {
      unique.putIfAbsent(example.sentence.toLowerCase(), () => example);
      if (unique.length >= limit) break;
    }
    return unique.values.toList();
  }

  Future<List<Example>> _fetch(
    String term, {
    required int limit,
    required bool requireTranslation,
    required TranslationLanguage translationLanguage,
  }) async {
    final query = <String, String>{
      'q': '=$term',
      'lang': 'eng',
      'is_unapproved': 'no',
      'is_orphan': 'no',
      'sort': 'random',
      'limit': '$limit',
      if (translationLanguage.hasTranslations) ...{
        'showtrans:lang': translationLanguage.tatoebaCode,
        'showtrans:is_direct': 'yes',
        'showtrans:is_unapproved': 'no',
      },
    };
    if (requireTranslation) {
      query
        ..['trans:lang'] = translationLanguage.tatoebaCode
        ..['trans:is_direct'] = 'yes'
        ..['trans:is_unapproved'] = 'no';
    }

    final response = await _client
        .get(
          Uri.https(_host, _path, query),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw ExampleSourceException('HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ExampleSourceException('Unexpected response format');
    }
    final data = decoded['data'];
    if (data is! List) return const [];

    final results = <Example>[];
    for (final item in data) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final sentence = (map['text'] ?? '').toString().trim();
      if (sentence.isEmpty) continue;

      var translation = '';
      final translations = map['translations'];
      if (translationLanguage.hasTranslations && translations is List) {
        for (final translated in translations) {
          if (translated is! Map) continue;
          final translatedMap = Map<String, dynamic>.from(translated);
          if (translatedMap['lang'] == translationLanguage.tatoebaCode) {
            translation = (translatedMap['text'] ?? '').toString().trim();
            if (translation.isNotEmpty) break;
          }
        }
      }

      results.add(
        Example(
          sentence: sentence,
          translation: translation,
          source: 'Tatoeba',
          sourceId: (map['id'] ?? '').toString(),
          license: (map['license'] ?? 'CC BY 2.0 FR').toString(),
        ),
      );
    }
    return results;
  }

  void dispose() => _client.close();
}

class ExampleSourceException implements Exception {
  final String message;
  const ExampleSourceException(this.message);

  @override
  String toString() => message;
}
