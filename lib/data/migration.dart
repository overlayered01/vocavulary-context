import '../models/word.dart';
import '../models/wordbook.dart';
import 'local_repository.dart';
import 'repository.dart';

/// 로컬 단어장을 클라우드로 복사한다.
///
/// 같은 id의 단어장이 이미 클라우드에 있으면 (과거에 이관된 것으로 보고)
/// 통째로 건너뛰어 중복·덮어쓰기를 막는다. 이관한 단어장 수를 돌려준다.
Future<int> migrateLocalToCloud(
  LocalRepository local,
  VocabRepository cloud,
) async {
  final localBooks = await local.getWordbooks();
  if (localBooks.isEmpty) return 0;
  final existing = (await cloud.getWordbooks()).map((b) => b.id).toSet();

  var migrated = 0;
  for (final book in localBooks) {
    if (existing.contains(book.id)) continue;
    await cloud.createWordbook(book);
    for (final word in await local.getWords(book.id)) {
      await cloud.upsertWord(word);
    }
    migrated++;
  }
  return migrated;
}

/// 공유/공개 단어장을 내 단어장으로 복제한다.
///
/// 새 id로 만들어 원본과 분리하고(비공개로 시작), 단어의 학습 상태(SRS)는
/// 초기화한다 — 복제한 사람 입장에선 처음 보는 단어이기 때문. 복제한 단어 수 반환.
Future<int> importSharedWordbook(
  VocabRepository repo,
  Wordbook source,
  List<Word> words,
) async {
  final now = DateTime.now();
  final created = await repo.createWordbook(
    Wordbook(
      id: '',
      ownerId: '',
      title: source.title,
      description: source.description,
      tags: source.tags,
      groups: source.groups,
      createdAt: now,
      updatedAt: now,
    ),
  );
  for (final w in words) {
    await repo.upsertWord(
      Word(
        id: '',
        wordbookId: created.id,
        group: w.group,
        term: w.term,
        meaning: w.meaning,
        partOfSpeech: w.partOfSpeech,
        phonetic: w.phonetic,
        imageUrl: w.imageUrl,
        examples: w.examples,
        favorite: w.favorite,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
  return words.length;
}
