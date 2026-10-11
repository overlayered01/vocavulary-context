import 'package:flutter/material.dart';

/// 바탕색(패널)과 포인트색 두 가지에서 화면 전체 색을 만든다.
///
/// 사용자가 직접 고른 색이어도 글자가 읽히도록 글자·보조색은 바탕색의
/// 밝기를 보고 자동으로 정한다.
class AppPalette {
  /// 짙은 패널(카드 덱이 놓이는 면) 색.
  final Color panel;

  /// 버튼·형광펜·진행 표시에 쓰는 포인트색.
  final Color point;

  final Color panelHigh;
  final Color panelLine;
  final Color onPanel;
  final Color onPanelSub;
  final Color ink;
  final Color sub;
  final Color sub2;
  final Color chip;
  final Color line;
  final Color tab;
  final Color onPoint;

  const AppPalette._({
    required this.panel,
    required this.point,
    required this.panelHigh,
    required this.panelLine,
    required this.onPanel,
    required this.onPanelSub,
    required this.ink,
    required this.sub,
    required this.sub2,
    required this.chip,
    required this.line,
    required this.tab,
    required this.onPoint,
  });

  factory AppPalette.from(Color panel, Color point) {
    final hsl = HSLColor.fromColor(panel);
    final h = hsl.hue;
    final s = hsl.saturation;
    Color tone(double sat, double light) => HSLColor.fromAHSL(
      1,
      h,
      sat.clamp(0.0, 1.0),
      light.clamp(0.0, 1.0),
    ).toColor();

    final ink = tone(s * 0.9, (hsl.lightness * 0.7).clamp(0.12, 0.22));
    final light = panel.computeLuminance() > 0.35;
    return AppPalette._(
      panel: panel,
      point: point,
      panelHigh: tone(s, hsl.lightness + (light ? -0.06 : 0.05)),
      panelLine: tone(s, hsl.lightness + (light ? -0.1 : 0.08)),
      onPanel: light ? ink : tone(s * 0.4, 0.93),
      onPanelSub: light ? tone(s * 0.5, 0.36) : tone(s * 0.5, 0.7),
      ink: ink,
      sub: tone(s * 0.45, 0.58),
      sub2: tone(s * 0.45, 0.46),
      chip: tone(s * 0.5, 0.94),
      line: tone(s * 0.4, 0.89),
      tab: tone(s * 0.6 + 0.08, 0.7),
      onPoint: point.computeLuminance() > 0.4 ? ink : Colors.white,
    );
  }

  bool get panelIsLight => panel.computeLuminance() > 0.35;

  static AppPalette current = AppPalette.from(
    AppThemes.slate.panel,
    AppThemes.slate.point,
  );
}

/// 설정 화면에서 고르는 테마 프리셋.
class AppThemePreset {
  final String id;
  final Color panel;
  final Color point;
  const AppThemePreset(this.id, this.panel, this.point);
}

class AppThemes {
  static const slate = AppThemePreset(
    'slate',
    Color(0xFF46544F),
    Color(0xFFF6C9A0),
  );
  static const navy = AppThemePreset(
    'navy',
    Color(0xFF1F2A36),
    Color(0xFF9ED8C6),
  );
  static const brown = AppThemePreset(
    'brown',
    Color(0xFF3A302B),
    Color(0xFFE9A27C),
  );
  static const plum = AppThemePreset(
    'plum',
    Color(0xFF3B3346),
    Color(0xFFF2B8C6),
  );
  static const charcoal = AppThemePreset(
    'charcoal',
    Color(0xFF262626),
    Color(0xFFF2E3A6),
  );
  static const presets = [slate, navy, brown, plum, charcoal];
  static const customId = 'custom';

  static AppPalette paletteFor(String id, Color customPanel, Color customPoint) {
    if (id == customId) return AppPalette.from(customPanel, customPoint);
    final preset = presets.firstWhere((p) => p.id == id, orElse: () => slate);
    return AppPalette.from(preset.panel, preset.point);
  }
}

/// 현재 테마 색. 테마를 바꾸면 [AppPalette.current]가 바뀌고 앱 전체가 다시 그려진다.
class AppColors {
  static AppPalette get _p => AppPalette.current;

  static Color get panel => _p.panel;
  static Color get panelHigh => _p.panelHigh;
  static Color get panelLine => _p.panelLine;
  static Color get onPanel => _p.onPanel;
  static Color get onPanelSub => _p.onPanelSub;
  static Color get point => _p.point;
  static Color get onPoint => _p.onPoint;
  static Color get tab => _p.tab;
  static Color get sub2 => _p.sub2;

  static Color get accent => _p.point;
  static Color get accentSoft => Color.lerp(_p.point, Colors.white, 0.6)!;
  static Color get accentDark => _p.ink;
  static Color get bg => _p.chip;
  static Color get ink => _p.ink;
  static Color get sub => _p.sub;
  static Color get line => _p.line;
  static const card = Color(0xFFFFFFFF);
  static Color get chip => _p.chip;
  static Color get ok => _p.ink;
  static const warn = Color(0xFF8A6D24);
}

/// 숫자·영어 단어를 표시하는 가는 글꼴.
const kDisplayFont = 'Outfit';

ThemeData buildAppTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.panel,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.ink,
        onPrimary: Colors.white,
        secondary: AppColors.point,
        onSecondary: AppColors.onPoint,
        primaryContainer: AppColors.accentSoft,
        onPrimaryContainer: AppColors.ink,
        surface: AppColors.card,
        onSurface: AppColors.ink,
        outline: AppColors.line,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.card,
    fontFamily: kDisplayFont,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontFamily: kDisplayFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.point,
        foregroundColor: AppColors.onPoint,
        elevation: 0,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: Colors.transparent,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(color: AppColors.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.chip,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.ink, width: 1.5),
      ),
      floatingLabelStyle: TextStyle(color: AppColors.ink),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.chip,
      selectedColor: AppColors.point,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.ink
            : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.point
            : AppColors.line,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.point,
      inactiveTrackColor: AppColors.chip,
      thumbColor: AppColors.ink,
      overlayColor: AppColors.point.withValues(alpha: 0.2),
      trackHeight: 6,
      tickMarkShape: SliderTickMarkShape.noTickMark,
      valueIndicatorColor: AppColors.ink,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.ink,
      linearTrackColor: AppColors.chip,
    ),
  );
}
