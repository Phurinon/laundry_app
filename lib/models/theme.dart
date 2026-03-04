import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Primary (Blue) ──
  static const Color primary = Color(0xFF1E90FF);
  static const Color primaryDark = Color(0xFF217CD2);
  static const Color primaryLight = Color(0xFFAFD5FB);
  static const Color primaryLightest = Color(0xFFEEF6FF);

  // ── Secondary (Green) ──
  static const Color secondary = Color(0xFF90EE90);
  static const Color secondaryDark = Color(0xFF77CA77);
  static const Color secondaryLight = Color(0xFFD6F9D6);
  static const Color secondaryLightest = Color(0xFFF3FDF0);

  // ── Accent (Cyan) ──
  static const Color accent = Color(0xFF40E0D0);
  static const Color accentDark = Color(0xFF27B0AE);
  static const Color accentLight = Color(0xFF88ECE2);
  static const Color accentLightest = Color(0xFFEDF9FA);

  // ── Neutral / Surface ──
  static const Color background = Color(0xFFF8FAFE);
  static const Color surface = Colors.white;
  static const Color neutral50 = Color(0xFFF8F7F8);
  static const Color neutral100 = Color(0xFFE8E8E8);
  static const Color neutral200 = Color(0xFFD0D0D5);
  static const Color neutral300 = Color(0xFFB8B8BD);
  static const Color neutral400 = Color(0xFF8B8B90);
  static const Color neutral500 = Color(0xFF6B6B70);
  static const Color neutral700 = Color(0xFF343847);
  static const Color neutral900 = Color(0xFF141B25);

  // ── Text ──
  static const Color textPrimary = Color(0xFF141B25);
  static const Color textSecondary = Color(0xFF6B6B70);

  // ── Utility ──
  static const Color error = Color(0xFFCA3A32);
  static const Color errorLight = Color(0xFFF0766F);
  static const Color success = Color(0xFF6BC293);
  static const Color warning = Color(0xFFE8A238);
  static const Color warningLight = Color(0xFFFFD015);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.prompt().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: textPrimary,
      iconTheme: IconThemeData(color: primary),
    ),

    // Card
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: primaryLight, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
    ),

    iconTheme: const IconThemeData(color: primary),
  );
}
