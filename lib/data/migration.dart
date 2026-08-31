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
