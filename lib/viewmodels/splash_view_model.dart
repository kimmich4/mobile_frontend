import 'package:flutter/material.dart';
import 'base_view_model.dart';

/// ViewModel for Splash Screen
class SplashViewModel extends BaseViewModel {
  late AnimationController mainController;
  late AnimationController pulseController;
  late AnimationController loadingController;
  
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> titleSlideAnimation;
  late Animation<double> subtitleFadeAnimation;
  late Animation<double> logoRotateAnimation;
  late Animation<double> pulseAnimation;

  bool _navigationStarted = false;
  bool isInitialized = false;

  /// Initialize all animations
  void initializeAnimations(TickerProvider vsync) {
    // Main entrance animation
    mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2500),
    );

    // Continuous pulse for the logo
    pulseController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Loading dots animation
    loadingController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    logoRotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    titleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
      ),
    );

    subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    mainController.forward();
    
    isInitialized = true;
    notifyListeners();
  }

  /// Schedule navigation to onboarding screen
  void scheduleNavigation(BuildContext context, VoidCallback onNavigate) {
    if (_navigationStarted) return;
    _navigationStarted = true;
    
    Future.delayed(const Duration(seconds: 4), () {
      if (!isDisposed) {
        onNavigate();
      }
    });
  }

  @override
  void dispose() {
    mainController.dispose();
    pulseController.dispose();
    loadingController.dispose();
    super.dispose();
  }
}
