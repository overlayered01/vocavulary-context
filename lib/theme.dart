import 'package:flutter/material.dart';

/// 모노크롬 미니멀 팔레트.
/// 강조색 없이 잉크(검정)·회색·순백 + 얇은 구분선만으로 위계를 표현한다.
class AppColors {
  /// 핵심 액션(버튼·아이콘)에 쓰는 잉크색. 과거 파란 강조색을 대체한다.
  static const accent = Color(0xFF111111);
  static const accentSoft = Color(0xFFF2F2F4);
  static const bg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111111);
  static const sub = Color(0xFF9A9AA2);
  static const line = Color(0xFFEDEDF0);

  /// 카드/패널 면. 순백 배경 위에서 살짝 떠 보이도록 한 톤 낮춘 회색.
  static const card = Color(0xFFF7F7F8);
  static const chip = Color(0xFFF1F1F3);

  /// 정답/오답 등 상태도 모노크롬으로 통일(아이콘·텍스트로 구분).
  static const ok = Color(0xFF111111);
  static const warn = Color(0xFF9A9AA2);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      primary: AppColors.ink,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.ink),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.line),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.line),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.ink, width: 1.5),
      ),
    ),
  );
}
