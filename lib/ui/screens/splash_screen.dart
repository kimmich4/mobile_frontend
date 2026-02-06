import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/splash_view_model.dart';
import 'onboarding_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SplashViewModel>(context, listen: false);
      viewModel.initializeAnimations(this);
      viewModel.scheduleNavigation(context, () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, child) {
        // Ensure animations are initialized to avoid null errors if build happens before init (rare but possible)
        if (!viewModel.isInitialized) {
           return Container(color: const Color(0xFF003135)); // Return background color while initializing
        }
        
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF003135), Color(0xFF024950), Color(0xFF003135)],
              ),
            ),
            child: Stack(
              children: [
                _buildAnimatedBackground(viewModel),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBeautifulLogo(viewModel),
                        const SizedBox(height: 40),
                        _buildAnimatedText(viewModel),
                        const SizedBox(height: 100),
                        _buildAnimatedLoadingDots(viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(SplashViewModel viewModel) {
    return AnimatedBuilder(
      animation: viewModel.pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0FA4AF).withOpacity(0.1 * viewModel.pulseAnimation.value)),
              ),
            ),
            Positioned(
              bottom: -150, right: -150,
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF964734).withOpacity(0.05 * viewModel.pulseAnimation.value)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBeautifulLogo(SplashViewModel viewModel) {
    return FadeTransition(
      opacity: viewModel.fadeAnimation,
      child: ScaleTransition(
        scale: viewModel.scaleAnimation,
        child: RotationTransition(
          turns: viewModel.logoRotateAnimation,
          child: ScaleTransition(
            scale: viewModel.pulseAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFF0FA4AF).withOpacity(0.4), Colors.transparent]),
                  ),
                ),
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFF0FA4AF).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(top: 30, child: Icon(Icons.restaurant_menu_rounded, size: 40, color: Color(0xFFAFDDE5))),
                      const Positioned(bottom: 30, child: Icon(Icons.fitness_center_rounded, size: 45, color: Colors.white)),
                      Container(width: 60, height: 2, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(SplashViewModel viewModel) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: viewModel.mainController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, viewModel.titleSlideAnimation.value),
              child: Opacity(
                opacity: viewModel.fadeAnimation.value,
                child: Column(
                  children: [
                    const Text('FitBite', style: TextStyle(color: Colors.white, fontSize: 56, fontFamily: 'Arial', fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10)])),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: viewModel.subtitleFadeAnimation.value,
                      child: const Text('PRECISION NUTRITION & FITNESS', style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 14, fontFamily: 'Arial', letterSpacing: 4, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedLoadingDots(SplashViewModel viewModel) {
    return FadeTransition(
      opacity: viewModel.subtitleFadeAnimation,
      child: AnimatedBuilder(
        animation: viewModel.loadingController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              double offset = (index * 0.2);
              double value = math.sin((viewModel.loadingController.value * 2 * math.pi) + (index * 1.0));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(const Color(0xFF0FA4AF), const Color(0xFFAFDDE5), (value + 1) / 2),
                  boxShadow: [BoxShadow(color: const Color(0xFF0FA4AF).withOpacity(0.3), blurRadius: 4, offset: Offset(0, value * 2))],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

