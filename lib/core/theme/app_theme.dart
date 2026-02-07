import 'package:flutter/material.dart';

/// Themes centralises pour garantir une apparence coherente.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData.light().copyWith(
      primaryColor: Colors.amber,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber).copyWith(
        surface: Colors.white,
        primary: Colors.amber,
        onPrimary: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFBB80A),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Color(0xFFFBB80A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFBB80A),
        foregroundColor: Colors.black,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.amber.shade700,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.amber,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.amber.shade700,
        onPrimary: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFBB80A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFFBB80A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFBB80A),
        foregroundColor: Colors.white,
      ),
    );
  }
}
