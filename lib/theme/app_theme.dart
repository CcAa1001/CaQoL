import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const background = Color(0xFF07070B);
  static const surface = Color(0xFF13131A);
  static const surfaceHigh = Color(0xFF1A1A24);
  static const border = Color(0xFF2A2A38);
  static const primary = Color(0xFF7B61FF);
  static const primaryDark = Color(0xFF5A41D0);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1B5);
  static const textTertiary = Color(0xFF6B6B80);
  static const success = Color(0xFF00E676);
  static const danger = Color(0xFFFF3B30);
  
  // Neon accents
  static const neonCyan = Color(0xFF00F0FF);
  static const neonPink = Color(0xFFFF0066);
  static const neonPurple = Color(0xFFB5179E);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [neonCyan, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const dangerGradient = LinearGradient(
    colors: [neonPink, danger],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const glowingShadow = BoxShadow(
    color: Color(0x6600F0FF),
    blurRadius: 20,
    spreadRadius: -5,
  );

  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
      ),
      useMaterial3: true,
      textTheme: baseTextTheme.copyWith(
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textPrimary),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: textTertiary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textTertiary, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceHigh,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }
}
