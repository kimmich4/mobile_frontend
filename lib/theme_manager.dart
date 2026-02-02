import 'package:flutter/material.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF024950),
      scaffoldBackgroundColor: const Color(0xFFAFDDE5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF024950),
        primary: const Color(0xFF024950),
        secondary: const Color(0xFF0FA4AF),
        surface: Colors.white,
        background: const Color(0xFFAFDDE5),
        onPrimary: Colors.white,
        onSurface: const Color(0xFF003135),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF003135),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF0FA4AF),
      scaffoldBackgroundColor: const Color(0xFF001F22),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0FA4AF),
        secondary: Color(0xFF964734),
        surface: Color(0xFF003135),
        background: Color(0xFF001F22),
        onPrimary: Colors.white,
        onSurface: Color(0xFFAFDDE5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF001F22),
        foregroundColor: Colors.white,
      ),
    );
  }
}
