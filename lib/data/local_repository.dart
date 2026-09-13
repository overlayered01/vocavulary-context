import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/study_log.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import 'repository.dart';
import 'sample_data.dart';

/// SharedPreferences 기반 로컬 저장소. Firebase 미설정/오프라인 시 사용한다.
/// 앱이 설정 없이도 즉시 동작하도록 보장하는 기본 구현.
class LocalRepository implements VocabRepository {
  static const _kWordbooks = 'wordbooks';
  static const _kWordsPrefix = 'words_';
  static const _kSeeded = 'seeded_v1';
  static const _kStudyLogs = 'study_logs';

  /// 로컬에 보관할 학습 기록 상한 (오래된 것부터 버림).
  static const _maxStudyLogs = 5000;

  final _uuid = const Uuid();
  late SharedPreferences _prefs;

  @override
  bool get isCloud => false;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (!(_prefs.getBool(_kSeeded) ?? false)) {
      await _seedSampleData();
      await _prefs.setBool(_kSeeded, true);
    }
  }

  Future<void> _seedSampleData() async {
    final (wb, words) = buildSampleData(_uuid.v4, () => _uuid.v4());
    await _saveWordbooks([wb]);
    await _saveWords(wb.id, words);
  }

  // ---- wordbooks ----
  Future<void> _saveWordbooks(List<Wordbook> list) async {
    await _prefs.setString(
      _kWordbooks,
      jsonEncode(list.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<Wordbook>> getWordbooks() async {
    final raw = _prefs.getString(_kWordbooks);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => Wordbook.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<Wordbook> createWordbook(Wordbook wb) async {
    final list = await getWordbooks();
    final created = wb.id.isEmpty
        ? Wordbook(
            id: _uuid.v4(),
            ownerId: wb.ownerId,
            title: wb.title,
            description: wb.description,
            tags: wb.tags,
            groups: wb.groups,
            visibility: wb.visibility,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : wb;
    list.add(created);
    await _saveWordbooks(list);
    return created;
  }

  @override
  Future<void> updateWordbook(Wordbook wb) async {
    final list = await getWordbooks();
    final idx = list.indexWhere((e) => e.id == wb.id);
    if (idx >= 0) {
      list[idx] = wb.copyWith(updatedAt: DateTime.now());
      await _saveWordbooks(list);
    }
  }

  @override
  Future<void> deleteWordbook(String id) async {
    final list = await getWordbooks()
      ..removeWhere((e) => e.id == id);
    await _saveWordbooks(list);
    await _prefs.remove('$_kWordsPrefix$id');
  }

  // ---- words ----
  Future<void> _saveWords(String wordbookId, List<Word> words) async {
    await _prefs.setString(
      '$_kWordsPrefix$wordbookId',
      jsonEncode(words.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<Word>> getWords(String wordbookId) async {
    final raw = _prefs.getString('$_kWordsPrefix$wordbookId');
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => Word.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<List<Word>> getAllWords() async {
    final books = await getWordbooks();
    final result = <Word>[];
    for (final wb in books) {
      result.addAll(await getWords(wb.id));
    }
    return result;
  }

  @override
  Future<Word> upsertWord(Word word) async {
    final words = await getWords(word.wordbookId);
    // id가 비어 있으면 신규 단어로 보고 새 id를 부여한다.
    final w = word.id.isEmpty
        ? Word(
            id: _uuid.v4(),
            wordbookId: word.wordbookId,
            group: word.group,
            term: word.term,
            meanings: word.meanings,
            dictionarySourceTerms: word.dictionarySourceTerms,
            partOfSpeech: word.partOfSpeech,
            phonetic: word.phonetic,
            imageUrl: word.imageUrl,
            examples: word.examples,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : word;
    final idx = words.indexWhere((e) => e.id == w.id);
    if (idx >= 0) {
      words[idx] = w;
    } else {
      words.add(w);
    }
    await _saveWords(word.wordbookId, words);
    return w;
  }

  @override
  Future<void> deleteWord(String wordbookId, String wordId) async {
    final words = await getWords(wordbookId)
      ..removeWhere((e) => e.id == wordId);
    await _saveWords(wordbookId, words);
  }

  // ---- study logs ----
  List<StudyLog> _loadStudyLogs() {
    final raw = _prefs.getString(_kStudyLogs);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => StudyLog.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> addStudyLog(StudyLog log) async {
    final logs = _loadStudyLogs()
      ..add(
        log.id.isEmpty
            ? StudyLog(
                id: _uuid.v4(),
                wordId: log.wordId,
                correct: log.correct,
                studiedAt: log.studiedAt,
              )
            : log,
      );
    final trimmed = logs.length > _maxStudyLogs
        ? logs.sublist(logs.length - _maxStudyLogs)
        : logs;
    await _prefs.setString(
      _kStudyLogs,
      jsonEncode(trimmed.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<List<StudyLog>> getStudyLogsSince(DateTime since) async {
    return _loadStudyLogs()
        .where((log) => !log.studiedAt.isBefore(since))
        .toList();
  }
}
