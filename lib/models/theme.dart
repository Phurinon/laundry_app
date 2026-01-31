import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFFC4B5FD);
  static const Color background = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: background,
      error: error,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textPrimary),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
