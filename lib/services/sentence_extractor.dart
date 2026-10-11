import 'local_dictionary.dart' show baseForms;

/// 사진에서 읽은 글을 문장으로 나누고 [term]이 들어간 문장만 고른다.
///
/// 줄 끝 하이픈으로 끊긴 단어는 다시 잇고 줄바꿈은 공백으로 바꾼다.
/// 마침표 없이 끝나는 짧은 줄(제목·쪽 번호 등) 뒤에서는 문장을 끊는다.
/// 단어는 앞부분이 같거나(charge → charged) 원형이 같으면(ran → run) 찾는다.
List<String> sentencesWithTerm(String text, String term, {int limit = 20}) {
  final query = term.trim().toLowerCase();
  if (query.isEmpty) return const [];
  final unhyphenated = text.replaceAllMapped(
    RegExp(r'([A-Za-z])-\s*\n\s*([a-z])'),
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
    final words = RegExp(
      r"[A-Za-z']+",
    ).allMatches(sentence).map((m) => m[0]!.toLowerCase()).toList();
    if (words.length < 3 || words.length > 40) continue;
    final has = words.any(
      (w) =>
          w.startsWith(query) ||
          (!query.contains(' ') && baseForms(w).contains(query)),
    );
    if (!has || !seen.add(sentence.toLowerCase())) continue;
    found.add(sentence);
    if (found.length >= limit) break;
  }
  return found;
}
