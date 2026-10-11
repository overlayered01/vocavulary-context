import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// 모든 테스트를 한국 기기 기준으로 실행한다. 언어별 동작은 각 테스트에서 직접 지정한다.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
  binding.platformDispatcher.localesTestValue = const [Locale('ko', 'KR')];
  await testMain();
}
