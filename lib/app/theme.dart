import 'package:flutter/material.dart';

abstract final class AppColors {
  // Theater-noir palette: ticket red, spotlight gold, and dark cinema blue.
  static const primary = Color(0xFFE63946);
  static const accent = Color(0xFFFFC857);
  static const locationBlue = Color(0xFF5B4B9A);
  static const success = Color(0xFF4D9B70);
  static const warning = Color(0xFFE7A928);
  static const surface = Color(0xFFF6F7FB);
  static const surfaceTint = Color(0xFFECEEF5);
  static const softAccent = Color(0xFFFFF1C7);
  static const coralWash = Color(0xFFFFE4E7);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF667085);
  static const border = Color(0xFFD7DBE7);
  static const midnight = Color(0xFF0B1020);
}

ThemeData buildTicketflixTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: AppColors.ink,
    tertiary: AppColors.locationBlue,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: AppColors.ink,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      headlineSmall: TextStyle(
        color: AppColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.35),
      bodyMedium: TextStyle(color: AppColors.ink, fontSize: 14, height: 1.35),
      bodySmall: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      labelStyle: const TextStyle(color: AppColors.ink),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      selectedColor: AppColors.softAccent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceTint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.softAccent,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.accent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
