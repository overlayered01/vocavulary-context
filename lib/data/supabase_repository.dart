import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/study_log.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import 'repository.dart';

/// Supabase(Postgres) 기반 클라우드 저장소. 로그인한 사용자 계정으로 기기 간 동기화.
///
/// 테이블 구조 (전체 직렬화는 jsonb `data` 컬럼에 저장, 인덱스/RLS용 키만 별도 컬럼):
///   wordbooks(id text pk, owner_id uuid, data jsonb, updated_at timestamptz)
///   words(id text pk, owner_id uuid, wordbook_id text,
///         data jsonb, created_at timestamptz, updated_at timestamptz)
///   study_logs(id text pk, owner_id uuid, data jsonb, studied_at timestamptz)
/// RLS: owner_id = auth.uid() 인 행만 읽기/쓰기 허용 (SUPABASE_설정가이드.md 참고).
class SupabaseRepository implements VocabRepository {
  final SupabaseClient _db = Supabase.instance.client;
  final _uuid = const Uuid();

  @override
  bool get isCloud => true;

  String get _uid => _db.auth.currentUser!.id;

  @override
  Future<void> init() async {}

  @override
  Future<List<Wordbook>> getWordbooks() async {
    // RLS가 공개(shared/public) 단어장도 읽게 허용하므로 내 것만 명시적으로 필터.
    final rows = await _db
        .from('wordbooks')
        .select('data')
        .eq('owner_id', _uid)
        .order('updated_at', ascending: false);
    return rows
        .map((r) => Wordbook.fromMap(Map<String, dynamic>.from(r['data'])))
        .toList();
  }

  @override
  Future<Wordbook> createWordbook(Wordbook wb) async {
    final id = wb.id.isEmpty ? _uuid.v4() : wb.id;
    final created = Wordbook(
      id: id,
      ownerId: _uid,
      title: wb.title,
      description: wb.description,
      tags: wb.tags,
      groups: wb.groups,
      visibility: wb.visibility,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.from('wordbooks').insert({
      'id': id,
      'owner_id': _uid,
      'data': created.toMap(),
      'updated_at': created.updatedAt.toIso8601String(),
    });
    return created;
  }

  @override
  Future<void> updateWordbook(Wordbook wb) async {
    final updated = wb.copyWith(updatedAt: DateTime.now());
    await _db
        .from('wordbooks')
        .update({
          'data': updated.toMap(),
          'updated_at': updated.updatedAt.toIso8601String(),
        })
        .eq('id', wb.id);
  }

  @override
  Future<void> deleteWordbook(String id) async {
    await _db.from('words').delete().eq('wordbook_id', id);
    await _db.from('wordbooks').delete().eq('id', id);
  }

  @override
  Future<List<Word>> getWords(String wordbookId) async {
    final rows = await _db
        .from('words')
        .select('data')
        .eq('owner_id', _uid)
        .eq('wordbook_id', wordbookId)
        .order('created_at', ascending: true);
    return rows
        .map((r) => Word.fromMap(Map<String, dynamic>.from(r['data'])))
        .toList();
  }

  @override
  Future<List<Word>> getAllWords() async {
    final rows = await _db
        .from('words')
        .select('data')
        .eq('owner_id', _uid)
        .order('created_at', ascending: true);
    return rows
        .map((r) => Word.fromMap(Map<String, dynamic>.from(r['data'])))
        .toList();
  }

  @override
  Future<Word> upsertWord(Word word) async {
    final id = word.id.isEmpty ? _uuid.v4() : word.id;
    final w = word.id.isEmpty
        ? Word(
            id: id,
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
        : word.copyWith(updatedAt: DateTime.now());
    await _db.from('words').upsert({
      'id': id,
      'owner_id': _uid,
      'wordbook_id': w.wordbookId,
      'data': w.toMap(),
      'created_at': w.createdAt.toIso8601String(),
      'updated_at': w.updatedAt.toIso8601String(),
    });
    return w;
  }

  @override
  Future<void> deleteWord(String wordbookId, String wordId) async {
    await _db.from('words').delete().eq('id', wordId);
  }

  @override
  Future<void> addStudyLog(StudyLog log) async {
    final l = log.id.isEmpty
        ? StudyLog(
            id: _uuid.v4(),
            wordId: log.wordId,
            correct: log.correct,
            studiedAt: log.studiedAt,
          )
        : log;
    await _db.from('study_logs').insert({
      'id': l.id,
      'owner_id': _uid,
      'data': l.toMap(),
      'studied_at': l.studiedAt.toIso8601String(),
    });
  }

  @override
  Future<List<StudyLog>> getStudyLogsSince(DateTime since) async {
    final rows = await _db
        .from('study_logs')
        .select('data')
        .eq('owner_id', _uid)
        .gte('studied_at', since.toIso8601String())
        .order('studied_at', ascending: true);
    return rows
        .map((r) => StudyLog.fromMap(Map<String, dynamic>.from(r['data'])))
        .toList();
  }

  // ---- 공유 · 탐색 (3단계, 클라우드 전용) ----
  // RLS의 "read shared wordbooks/words" 정책이 있어야 동작한다 (설정가이드 참고).

  /// 다른 사용자가 공개(public)로 전환한 단어장 목록. 내 것은 제외.
  Future<List<Wordbook>> getPublicWordbooks() async {
    final rows = await _db
        .from('wordbooks')
        .select('data')
        .eq('data->>visibility', Visibility.public.name)
        .neq('owner_id', _uid)
        .order('updated_at', ascending: false)
        .limit(50);
    return rows
        .map((r) => Wordbook.fromMap(Map<String, dynamic>.from(r['data'])))
        .toList();
  }

  /// 공유 코드(단어장 id)로 shared/public 단어장을 조회. 없거나 비공개면 null.
  Future<Wordbook?> getSharedWordbook(String code) async {
    final row = await _db
        .from('wordbooks')
        .select('data')
        .eq('id', code.trim())
        .maybeSingle();
    if (row == null) return null;
    final book = Wordbook.fromMap(Map<String, dynamic>.from(row['data']));
    return book.visibility == Visibility.private ? null : book;
  }

  /// shared/public 단어장의 단어 목록 (소유자 무관 — 복제용 읽기).
  Future<List<Word>> getSharedWords(String wordbookId) async {
    final rows = await _db
        .from('words')
        .select('data')
        .eq('wordbook_id', wordbookId)
        .order('created_at', ascending: true);
    return rows
        .map((r) => Word.fromMap(Map<String, dynamic>.from(r['data'])))
        .toList();
  }
}
