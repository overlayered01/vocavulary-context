import 'package:flutter/material.dart';

/// 밝은 라임 포인트와 따뜻한 뉴트럴 톤을 사용하는 공통 팔레트.
class AppColors {
  static const accent = Color(0xFFA7E63D);
  static const accentSoft = Color(0xFFE8F8C8);
  static const accentDark = Color(0xFF557D12);
  static const bg = Color(0xFFF4F5F1);
  static const ink = Color(0xFF171A16);
  static const sub = Color(0xFF7D8178);
  static const line = Color(0xFFE5E8E0);
  static const card = Color(0xFFFFFFFF);
  static const chip = Color(0xFFEEF0EA);
  static const ok = Color(0xFF557D12);
  static const warn = Color(0xFF8A6D24);
}

ThemeData buildAppTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.accent,
        onPrimary: AppColors.ink,
        primaryContainer: AppColors.accentSoft,
        onPrimaryContainer: AppColors.ink,
        surface: AppColors.card,
        onSurface: AppColors.ink,
        outline: AppColors.line,
      );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.card,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accentDark, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: AppColors.accentDark),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.accentSoft,
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 72,
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.accent,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStatePropertyAll(IconThemeData(size: 22)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentDark,
      linearTrackColor: AppColors.accentSoft,
    ),
  );
}
