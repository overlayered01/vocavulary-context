import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/word.dart';

/// Tatoeba의 공개 API에서 영어 예문과 가능한 한국어 번역을 가져온다.
class ExampleSourceService {
  final http.Client _client;
  final _cache = <(String, int), ({List<Example> values, DateTime expires})>{};
  final _pending = <(String, int), Future<List<Example>>>{};

  ExampleSourceService({http.Client? client})
    : _client = client ?? http.Client();

  static const _host = 'api.tatoeba.org';
  static const _path = '/v1/sentences';

  Future<List<Example>> fetchExamples(String term, {int limit = 6}) async {
    final query = term.trim();
    if (query.isEmpty) return const [];
    final key = (query, limit);
    final cached = _cache[key];
    if (cached != null && cached.expires.isAfter(DateTime.now())) {
      return cached.values;
    }
    final inFlight = _pending[key];
    if (inFlight != null) return inFlight;
    final request = _loadExamples(query, limit: limit);
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

  Future<List<Example>> _loadExamples(String term, {required int limit}) async {
    final normalized = term.trim();
    if (normalized.isEmpty) return const [];

    // 한국어 직역이 있는 문장을 먼저 가져오고, 부족한 수만큼 영어 문장으로
    // 채운다. 고급 단어는 한국어 번역이 없는 경우가 많기 때문이다.
    final translated = await _fetch(
      normalized,
      limit: limit,
      requireKorean: true,
    );
    if (translated.length >= limit) return translated.take(limit).toList();

    final List<Example> english;
    try {
      english = await _fetch(normalized, limit: limit, requireKorean: false);
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
    required bool requireKorean,
  }) async {
    final query = <String, String>{
      'q': '=$term',
      'lang': 'eng',
      'is_unapproved': 'no',
      'is_orphan': 'no',
      'sort': 'random',
      'limit': '$limit',
      'showtrans:lang': 'kor',
      'showtrans:is_direct': 'yes',
      'showtrans:is_unapproved': 'no',
    };
    if (requireKorean) {
      query
        ..['trans:lang'] = 'kor'
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
      throw ExampleSourceException('예문 서버 응답 오류 (${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ExampleSourceException('예문 응답 형식이 올바르지 않습니다.');
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
      if (translations is List) {
        for (final translated in translations) {
          if (translated is! Map) continue;
          final translatedMap = Map<String, dynamic>.from(translated);
          if (translatedMap['lang'] == 'kor') {
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
