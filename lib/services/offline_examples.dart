import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/translation_language.dart';
import '../models/word.dart';
import 'local_dictionary.dart' show baseForms;

/// 앱에 내장한 Tatoeba 예문. 문장마다 품사를 미리 붙여 두어서
/// 카드의 품사로 쓰인 문장만 고를 수 있고, 인터넷 없이도 쓴다.
///
/// `tool/build_examples.py`로 만든 `assets/examples/en.json`(영어 문장과
/// "단어|품사" 색인)을 처음 쓸 때 읽는다. 해석은 [translations]가 준다
/// (언어별로 내려받는 TranslationPacks). 해석을 못 받으면 문장만 돌려준다.
class OfflineExamples {
  final Future<String> Function(String path) _loadAsset;
  final Future<Map<String, String>> Function(TranslationLanguage language)?
  _translations;
  Future<_Index?>? _index;

  OfflineExamples({
    Future<String> Function(String path)? loadAsset,
    Future<Map<String, String>> Function(TranslationLanguage language)?
    translations,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString,
       _translations = translations;

  /// 저장용 품사 값(한국어 품사명이나 영어 키) → 색인의 품사 키.
  static String? indexPos(String partOfSpeech) => switch (partOfSpeech) {
    '명사' || 'noun' => 'noun',
    '동사' || '구동사' || 'verb' => 'verb',
    '형용사' || 'adjective' || 'adj' => 'adjective',
    '부사' || 'adverb' || 'adv' => 'adverb',
    _ => null,
  };

  /// [term]이 [partOfSpeech]로 쓰인 내장 예문. 품사 색인이 없는 품사면 빈 목록.
  /// 품사를 모르면(빈 문자열) 명사·동사·형용사·부사 예문을 모두 찾는다.
  /// [translationLanguage]가 영어거나 null이면 해석 없이 돌려준다.
  Future<List<Example>> find(
    String term,
    String partOfSpeech, {
    TranslationLanguage? translationLanguage,
  }) async {
    final pos = indexPos(partOfSpeech);
    final poses = pos != null
        ? [pos]
        : partOfSpeech.trim().isEmpty
        ? const ['noun', 'verb', 'adjective', 'adverb']
        : const <String>[];
    final query = term.trim().toLowerCase();
    if (poses.isEmpty || query.isEmpty || query.contains(' ')) return const [];
    final index = await (_index ??= _loadIndex());
    if (index == null) return const [];
    final ids = <Object?>{};
    for (final p in poses) {
      for (final form in [query, ...baseForms(query)]) {
        final found = index.keys['$form|$p'] as List?;
        if (found != null) {
          ids.addAll(found);
          break;
        }
      }
    }
    if (ids.isEmpty) return const [];
    var translations = const <String, String>{};
    if (translationLanguage != null &&
        translationLanguage.hasTranslations &&
        _translations != null) {
      try {
        translations = await _translations(translationLanguage);
      } catch (_) {
        // 해석 없이 문장만 쓴다.
      }
    }
    final found = [
      for (final id in ids)
        if (index.sentences[id.toString()] case final String sentence)
          Example(
            sentence: sentence,
            translation: translations[id.toString()] ?? '',
            source: 'Tatoeba',
            sourceId: id.toString(),
            license: 'CC BY 2.0 FR',
          ),
    ];
    // 해석이 있는 문장을 앞으로.
    final translated = [
      for (final e in found)
        if (e.translation.isNotEmpty) e,
    ];
    return [
      ...translated,
      for (final e in found)
        if (e.translation.isEmpty) e,
    ];
  }

  Future<_Index?> _loadIndex() async {
    try {
      final data =
          jsonDecode(await _loadAsset('assets/examples/en.json'))
              as Map<String, dynamic>;
      return (
        sentences: (data['sentences'] as Map).cast<String, dynamic>(),
        keys: (data['index'] as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      // 없거나 손상되면 온라인 예문만 쓴다. 다음 조회에서 다시 시도한다.
      _index = null;
      return null;
    }
  }
}

typedef _Index = ({Map<String, dynamic> sentences, Map<String, dynamic> keys});
