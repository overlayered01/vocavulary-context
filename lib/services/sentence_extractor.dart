import 'local_dictionary.dart' show baseForms;

/// 사진에서 읽은 글을 문장으로 나누고 [term]이 들어간 문장만 고른다.
///
/// 줄 끝 하이픈으로 끊긴 단어는 다시 잇고 줄바꿈은 공백으로 바꾼다.
/// 마침표 없이 끝나는 짧은 줄(제목·쪽 번호 등) 뒤에서는 문장을 끊는다.
/// 단어는 앞부분이 같거나(charge → charged) 원형이 같으면(ran → run) 찾는다.
/// 여러 단어로 된 말(give up)은 단어가 차례로 이어진 문장을 찾고,
/// 첫 단어와 마지막 단어만 활용형(gave up, gives up)을 허용한다.
/// 둥근 아포스트로피(don’t)와 악센트 글자(café)도 같은 단어로 본다.
List<String> sentencesWithTerm(String text, String term, {int limit = 20}) {
  final query = _words(term);
  if (query.isEmpty) return const [];
  final unhyphenated = text.replaceAllMapped(
    RegExp(r'(\p{L})-\s*\n\s*(\p{Ll})', unicode: true),
    (m) => '${m[1]}${m[2]}',
  );
  final lines = unhyphenated.split('\n');
  final buffer = StringBuffer();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    buffer.write(line);
    final next = i + 1 < lines.length ? lines[i + 1].trim() : '';
    final heading =
        line.split(' ').length <= 4 &&
        !RegExp(r'''[.!?,;:"”’)]$''').hasMatch(line) &&
        RegExp(r'^[A-Z0-9"“]').hasMatch(next);
    buffer.write(heading ? '\n' : ' ');
  }
  final sentences = [
    for (final block in buffer.toString().split('\n'))
      ...block
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .split(RegExp(r'''(?<=[.!?]["”’)]?)\s+(?=["“‘(]?[A-Z0-9])''')),
  ];
  final seen = <String>{};
  final found = <String>[];
  for (final raw in sentences) {
    final sentence = raw.trim();
    final words = _words(sentence);
    if (words.length < 3 || words.length > 40) continue;
    if (!_containsTerm(words, query) || !seen.add(sentence.toLowerCase())) {
      continue;
    }
    found.add(sentence);
    if (found.length >= limit) break;
  }
  return found;
}

final _apostrophes = RegExp('[‘’ʼ]');
final _word = RegExp(r"[\p{L}\p{M}']+", unicode: true);
final _edgeQuotes = RegExp(r"^'+|'+$");

/// 글을 소문자 단어로 나눈다. 둥근 아포스트로피는 '로 바꾸고 앞뒤 따옴표는 뗀다.
List<String> _words(String text) => [
  for (final m in _word.allMatches(text.replaceAll(_apostrophes, "'")))
    if (m[0]!.replaceAll(_edgeQuotes, '') case final w when w.isNotEmpty)
      w.toLowerCase(),
];

/// [query] 단어들이 [words] 안에 차례로 이어져 있는지.
/// 한 단어면 예전처럼 앞부분이 같거나 원형이 같은 단어를 찾는다.
bool _containsTerm(List<String> words, List<String> query) {
  final last = query.length - 1;
  bool matches(String word, String q, bool inflect) =>
      word == q ||
      (inflect && (word.startsWith(q) || baseForms(word).contains(q)));
  for (var i = 0; i + last < words.length; i++) {
    var ok = true;
    for (var j = 0; j <= last && ok; j++) {
      ok = matches(words[i + j], query[j], j == 0 || j == last);
    }
    if (ok) return true;
  }
  return false;
}
