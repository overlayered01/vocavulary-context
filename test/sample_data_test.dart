import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/data/local_repository.dart';

void main() {
  test('첫 실행에는 Default 단어장에 welcome 한 단어를 번역 언어로 넣는다', () async {
    SharedPreferences.setMockInitialValues({
      'app_settings': '{"translationLanguage":"ko"}',
    });
    final repo = LocalRepository();
    await repo.init();
    final books = await repo.getWordbooks();
    expect(books.map((b) => b.title), ['Default']);
    final words = await repo.getWords(books.single.id);
    expect(words.single.term, 'welcome');
    expect(words.single.meanings, ['환영합니다, 어서 오세요']);
    expect(words.single.examples.first.translation, contains('환영합니다'));

    // 다시 열어도 또 넣지 않는다.
    final again = LocalRepository();
    await again.init();
    expect(await again.getWordbooks(), hasLength(1));
  });
}
