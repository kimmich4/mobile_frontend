import 'package:flutter/material.dart';
import 'base_view_model.dart';

/// viewmodel for onboarding screen
class OnboardingViewModel extends BaseViewModel {
  final PageController pageController = PageController();
  int _currentPage = 0;

  int get currentPage => _currentPage;

  /// update current page index
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  /// navigate to next page or complete onboarding
  void nextPage(BuildContext context, VoidCallback onComplete) {
    if (_currentPage < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      onComplete();
    }
  }

  /// skip onboarding and go to auth screen
  void skipOnboarding(VoidCallback onComplete) {
    onComplete();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
