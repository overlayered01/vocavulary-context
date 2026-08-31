import '../models/word.dart';
import '../models/wordbook.dart';

/// 데이터 접근 추상화. 로컬 저장소와 Firebase 구현을 교체할 수 있게 한다.
/// (기술스택비교 문서의 'Repository 패턴으로 백엔드 교체 비용을 낮춘다' 전략)
abstract class VocabRepository {
  Future<void> init();

  Future<List<Wordbook>> getWordbooks();
  Future<Wordbook> createWordbook(Wordbook wb);
  Future<void> updateWordbook(Wordbook wb);
  Future<void> deleteWordbook(String id);

  Future<List<Word>> getWords(String wordbookId);

  /// 모든 단어장의 단어 (복습 세션 구성용).
  Future<List<Word>> getAllWords();

  Future<Word> upsertWord(Word word);
  Future<void> deleteWord(String wordbookId, String wordId);

  /// 클라우드 동기화 모드 여부 (Firebase 로그인 상태).
  bool get isCloud;
}
