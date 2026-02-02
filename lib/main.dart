import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme_manager.dart';

void main() {
  runApp(const FitBiteApp());
}

class FitBiteApp extends StatelessWidget {
  const FitBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'FitBite',
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
