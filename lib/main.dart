import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const FitBiteApp());
}

class FitBiteApp extends StatelessWidget {
  const FitBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF024950)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
