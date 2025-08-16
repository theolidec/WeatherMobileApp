import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade700,
        secondary: Colors.blue.shade500,
        surface: Colors.white,
        background: Colors.grey.shade50,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300,
        secondary: Colors.blue.shade200,
        surface: Colors.grey.shade900,
        background: Colors.grey.shade900,
        onPrimary: Colors.black87,
        onSecondary: Colors.black87,
        onSurface: Colors.white,
        onBackground: Colors.white,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
