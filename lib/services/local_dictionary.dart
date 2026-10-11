import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/translation_language.dart';

/// 내장 사전의 한 품사 항목. [headword]는 실제로 찾은 표제어(기본형일 수 있음).
class LocalDictionaryEntry {
  final String headword;
  final String partOfSpeech;
  final List<String> glosses;

  /// 이 품사의 사전 예문 (영어 문장, 번역). 번역이 없으면 빈 문자열.
  final List<(String, String)> examples;
  const LocalDictionaryEntry({
    required this.headword,
    required this.partOfSpeech,
    required this.glosses,
    this.examples = const [],
  });
}

/// 앱에 내장한 언어판 Wiktionary 사전(영어 표제어 → 번역 언어 풀이).
///
/// `tool/build_dictionary.py`로 만든 `assets/dictionaries/<code>.json`을 처음 쓸 때
/// 한 번 읽는다. 없는 단어는 기본형(went → go, services → service)으로 다시 찾는다.
class LocalDictionary {
  static const available = {
    TranslationLanguage.korean,
    TranslationLanguage.japanese,
    TranslationLanguage.chinese,
  };

  final Future<String> Function(String path) _loadAsset;
  final _loaded = <TranslationLanguage, Future<_DictionaryData?>>{};

  LocalDictionary({Future<String> Function(String path)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  Future<List<LocalDictionaryEntry>> lookup(
    String term,
    TranslationLanguage language,
  ) async {
    if (!available.contains(language)) return const [];
    final query = term.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final data = await (_loaded[language] ??= _load(language));
    if (data == null) return const [];
    for (final form in [query, ...baseForms(query)]) {
      // took → take처럼 사전이 알려주는 기본형을 먼저 따른다.
      final candidate = data.entries.containsKey(form)
          ? form
          : data.redirects[form] ?? form;
      final raw = data.entries[candidate];
      if (raw is! List) continue;
      return [
        for (final item in raw)
          if (item is List && item.length >= 2 && item[1] is List)
            LocalDictionaryEntry(
              headword: candidate,
              partOfSpeech: item[0] as String,
              glosses: (item[1] as List).whereType<String>().toList(),
              examples: [
                if (item.length > 2 && item[2] is List)
                  for (final pair in (item[2] as List).whereType<List>())
                    if (pair.isNotEmpty && pair[0] is String)
                      (
                        pair[0] as String,
                        pair.length > 1 && pair[1] is String
                            ? pair[1] as String
                            : '',
                      ),
              ],
            ),
      ];
    }
    return const [];
  }

  Future<_DictionaryData?> _load(TranslationLanguage language) async {
    try {
      final text = await _loadAsset(
        'assets/dictionaries/${language.code}.json',
      );
      final data = jsonDecode(text) as Map<String, dynamic>;
      return (
        entries: (data['entries'] as Map).cast<String, dynamic>(),
        redirects: ((data['redirects'] as Map?) ?? const {})
            .cast<String, String>(),
      );
    } catch (_) {
      // 사전이 없거나 손상되면 온라인 사전만 쓴다. 다음 조회에서 다시 시도한다.
      _loaded.remove(language);
      return null;
    }
  }
}

typedef _DictionaryData = ({
  Map<String, dynamic> entries,
  Map<String, String> redirects,
});

const _irregular = {
  'was': 'be',
  'were': 'be',
  'been': 'be',
  'is': 'be',
  'are': 'be',
  'am': 'be',
  'did': 'do',
  'done': 'do',
  'does': 'do',
  'had': 'have',
  'has': 'have',
  'went': 'go',
  'gone': 'go',
  'made': 'make',
  'took': 'take',
  'taken': 'take',
  'got': 'get',
  'gotten': 'get',
  'saw': 'see',
  'seen': 'see',
  'came': 'come',
  'knew': 'know',
  'known': 'know',
  'gave': 'give',
  'given': 'give',
  'said': 'say',
  'told': 'tell',
  'found': 'find',
  'thought': 'think',
  'brought': 'bring',
  'bought': 'buy',
  'caught': 'catch',
  'taught': 'teach',
  'began': 'begin',
  'begun': 'begin',
  'met': 'meet',
  'left': 'leave',
  'felt': 'feel',
  'kept': 'keep',
  'held': 'hold',
  'stood': 'stand',
  'lost': 'lose',
  'paid': 'pay',
  'sent': 'send',
  'built': 'build',
  'spent': 'spend',
  'won': 'win',
  'wrote': 'write',
  'written': 'write',
  'ran': 'run',
  'ate': 'eat',
  'eaten': 'eat',
  'fell': 'fall',
  'fallen': 'fall',
  'led': 'lead',
  'meant': 'mean',
  'sold': 'sell',
  'spoke': 'speak',
  'spoken': 'speak',
  'chose': 'choose',
  'chosen': 'choose',
  'forgot': 'forget',
  'forgotten': 'forget',
  'sought': 'seek',
  'drove': 'drive',
  'driven': 'drive',
  'broke': 'break',
  'broken': 'break',
  'rose': 'rise',
  'risen': 'rise',
  'grew': 'grow',
  'grown': 'grow',
  'drew': 'draw',
  'drawn': 'draw',
  'flew': 'fly',
  'flown': 'fly',
  'wore': 'wear',
  'worn': 'wear',
  'slept': 'sleep',
  'children': 'child',
  'men': 'man',
  'women': 'woman',
  'people': 'person',
  'feet': 'foot',
  'teeth': 'tooth',
  'mice': 'mouse',
  'better': 'good',
  'best': 'good',
  'worse': 'bad',
  'worst': 'bad',
};

/// 활용형의 기본형 후보. 사전에 있는 첫 후보를 쓰므로 순서가 중요하다.
List<String> baseForms(String word) {
  final candidates = <String>[?_irregular[word]];
  void add(String suffix, String replacement) {
    if (!word.endsWith(suffix) || word.length - suffix.length < 3) return;
    final base = word.substring(0, word.length - suffix.length) + replacement;
    candidates.add(base);
    // running → runn → run
    if (replacement.isEmpty &&
        base.length >= 3 &&
        base[base.length - 1] == base[base.length - 2]) {
      candidates.add(base.substring(0, base.length - 1));
    }
  }

  add('ies', 'y');
  add('ied', 'y');
  add('es', '');
  add('s', '');
  add('ed', 'e');
  add('ed', '');
  add('ing', 'e');
  add('ing', '');
  add('ier', 'y');
  add('iest', 'y');
  add('er', '');
  add('est', '');
  add('ly', '');
  return [
    for (final c in candidates.toSet())
      if (c != word) c,
  ];
}
