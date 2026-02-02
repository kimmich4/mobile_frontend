import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'animate_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: const [OnboardingScreen1(), OnboardingScreen2(), OnboardingScreen3()],
          ),
          Positioned(right: 24, top: 24, child: SafeArea(child: GestureDetector(onTap: _completeOnboarding, child: Text('Skip', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16))))),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: AnimateIn(
                delay: const Duration(milliseconds: 500),
                slideOffset: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentPage == index ? 32 : 8, height: 8,
                          decoration: BoxDecoration(color: Color(_currentPage == index ? 0xFF024950 : 0x4C024950), borderRadius: BorderRadius.circular(4)),
                        )),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: double.infinity, height: 56,
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(14)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(_currentPage == 2 ? 'Get Started' : 'Next', style: const TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface])),
      child: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 2),
          AnimateIn(child: Container(width: 128, height: 128, decoration: const BoxDecoration(color: Color(0x1F0FA4AF), shape: BoxShape.circle), child: const Icon(Icons.restaurant_menu, size: 64, color: Color(0xFF0FA4AF)))),
          const SizedBox(height: 32),
          AnimateIn(delay: const Duration(milliseconds: 200), child: Text('Personalized Diet Plans', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 400), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Text('Get customized meal plans based on your health data, allergies, and fitness goals.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 16)))),
          const Spacer(flex: 3),
        ]),
      ),
    );
  }
}

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface])),
      child: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 2),
          AnimateIn(child: Container(width: 128, height: 128, decoration: const BoxDecoration(color: Color(0x1F964734), shape: BoxShape.circle), child: const Icon(Icons.psychology, size: 64, color: Color(0xFF964734)))),
          const SizedBox(height: 32),
          AnimateIn(delay: const Duration(milliseconds: 200), child: Text('AI-Powered Recommendations', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 400), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Text('Our RAG-based AI assistant learns from your progress and provides intelligent advice.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 16)))),
          const Spacer(flex: 3),
        ]),
      ),
    );
  }
}

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface])),
      child: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 2),
          AnimateIn(child: Container(width: 128, height: 128, decoration: const BoxDecoration(color: Color(0x1F024950), shape: BoxShape.circle), child: const Icon(Icons.fitness_center, size: 64, color: Color(0xFF024950)))),
          const SizedBox(height: 32),
          AnimateIn(delay: const Duration(milliseconds: 200), child: Text('Smart Fitness Tracking', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 400), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Text('Track your progress with detailed analytics and workout plans tailored to you.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 16)))),
          const Spacer(flex: 3),
        ]),
      ),
    );
  }
}
