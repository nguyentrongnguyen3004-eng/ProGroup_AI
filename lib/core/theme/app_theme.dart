import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF0EA5E9);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF0F172A);
  static const Color grayColor = Color(0xFF64748B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}