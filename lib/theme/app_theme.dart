import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palettes (Obsidian Tech & Electric Violet/Cyan)
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color cardSurface = Color(0xFF131A2A);
  static const Color cardSurfaceLight = Color(0xFF1E283F);
  static const Color borderColor = Color(0xFF26324D);

  // Accents
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFA78BFA);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFF67E8F9);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color roseDanger = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryViolet,
      colorScheme: const ColorScheme.dark(
        primary: primaryViolet,
        secondary: neonCyan,
        surface: cardSurface,
        error: roseDanger,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1524),
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
