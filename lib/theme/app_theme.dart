import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceHigh = Color(0xFF242424);
  static const border = Color(0xFF2E2E2E);
  static const primary = Color(0xFFE8A020);
  static const primaryDark = Color(0xFFB07818);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9A9A9A);
  static const textTertiary = Color(0xFF5A5A5A);
  static const success = Color(0xFF4CAF50);
  static const danger = Color(0xFFE53935);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: surface,
      background: background,
    ),
    useMaterial3: true,
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withOpacity(0.15),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: textTertiary, fontSize: 11);
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: primary, size: 22);
        }
        return const IconThemeData(color: textTertiary, size: 22);
      }),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 0.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 0.5),
  );
}
