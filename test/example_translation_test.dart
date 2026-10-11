import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary/widgets/panel.dart';

String? focus(String translation, List<String> meanings) {
  final range = ExampleTranslation.focusOf(translation, meanings);
  return range == null ? null : translation.substring(range.$1, range.$2);
}

void main() {
  test('활용형으로 바뀐 뜻도 찾아 어절 끝까지 굵게 한다', () {
    expect(focus('그는 사기죄로 기소되었다.', ['기소하다', '청구하다']), '기소되었다');
    expect(focus('스펀지는 물을 잘 흡수한다.', ['흡수하다']), '흡수한다');
    expect(focus('정말 아름다운 경치였어요.', ['아름다운']), '아름다운');
  });

  test('여러 뜻 중 맞는 것을 고르고, 괄호 설명은 무시한다', () {
    expect(focus('그녀는 그 계획을 포기했다.', ['(계획을) 포기하다', '버리다']), '포기했다');
    expect(focus('개를 버리지 마세요.', ['포기하다; 버리다']), '버리지');
  });

  test('띄어 쓰지 않는 언어는 맞은 부분만, 못 찾으면 null', () {
    expect(focus('彼はその計画を放棄した。', ['放棄する']), '放棄');
    expect(focus('오늘은 날씨가 좋다.', ['기소하다']), isNull);
  });

  test('한 글자 뜻은 어절 첫머리에서만', () {
    expect(focus('눈이 많이 왔다.', ['눈']), '눈이');
    expect(focus('그는 안경을 썼다.', ['경']), isNull);
  });
}
