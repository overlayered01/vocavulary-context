import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/models/app_settings.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/screens/settings_screen.dart';
import 'package:vocabulary/theme.dart';

void main() {
  testWidgets('알람 구간을 추가·편집·삭제하고 기기에 저장한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(420, 2600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 기본 구간: 09:00–21:00, 3시간마다, 3장.
    expect(find.text('09:00 – 21:00'), findsOneWidget);
    expect(find.text('매일 · 3시간마다 · 3장'), findsOneWidget);
    expect(find.text('일주일 35회'), findsOneWidget);

    await tester.tap(find.text('알림 구간'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('단어 수 늘리기'));
    await tester.tap(find.byTooltip('단어 수 늘리기'));
    await tester.pumpAndSettle();
    expect(find.text('5장'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('reminder-preview')),
      findsOneWidget,
    );
    expect(find.text('하루 5회 · 25장'), findsOneWidget);
    // 요일을 모두 풀면 저장할 수 없다.
    for (final day in ['월', '화', '수', '목', '금', '토', '일']) {
      await tester.tap(find.text(day));
    }
    await tester.pumpAndSettle();
    expect(find.text('요일을 하나 이상 선택해 주세요.'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const ValueKey('reminder-save')))
          .onPressed,
      isNull,
    );
    for (final day in ['월', '화', '수', '목', '금']) {
      await tester.tap(find.text(day));
    }
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reminder-save')));
    await tester.pumpAndSettle();

    var stored = await AppSettings.load(prefs);
    expect(stored.reminderSchedules, hasLength(2));
    expect(stored.reminderSchedules.last.wordCount, 5);
    expect(stored.reminderSchedules.last.weekdays, [1, 2, 3, 4, 5]);
    expect(find.text('평일 · 3시간마다 · 5장'), findsOneWidget);

    // 첫 구간을 끈다.
    final firstRow = find.ancestor(
      of: find.text('매일 · 3시간마다 · 3장'),
      matching: find.byType(InkWell),
    );
    await tester.tap(
      find.descendant(of: firstRow.first, matching: find.byType(Switch)),
    );
    await tester.pumpAndSettle();
    stored = await AppSettings.load(prefs);
    expect(stored.reminderSchedules.first.enabled, isFalse);

    // 두 번째 구간을 삭제한다.
    await tester.tap(find.text('평일 · 3시간마다 · 5장'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    stored = await AppSettings.load(prefs);
    expect(stored.reminderSchedules, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('테마 프리셋과 직접 지정한 색을 저장한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(420, 2600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('theme-navy')));
    await tester.pumpAndSettle();
    expect((await AppSettings.load(prefs)).themeId, 'navy');

    await tester.tap(find.byKey(const ValueKey('theme-custom')));
    await tester.pumpAndSettle();
    expect(find.text('테마 직접 지정'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '#123456');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-apply')));
    await tester.pumpAndSettle();
    final stored = await AppSettings.load(prefs);
    expect(stored.themeId, 'custom');
    expect(stored.customThemeBase & 0xFFFFFF, 0x123456);
    expect(tester.takeException(), isNull);
  });

  test('직접 고른 밝은 바탕에서도 글자 색을 읽을 수 있게 맞춘다', () {
    final light = AppPalette.from(const Color(0xFFF2E3A6), Colors.white);
    expect(light.panelIsLight, isTrue);
    expect(light.onPanel, light.ink);
    expect(light.onPoint, light.ink);
    final dark = AppPalette.from(const Color(0xFF1F2A36), const Color(0xFF2C4BFF));
    expect(dark.onPoint, Colors.white);
    expect(dark.onPanel.computeLuminance(), greaterThan(0.7));
  });
}
