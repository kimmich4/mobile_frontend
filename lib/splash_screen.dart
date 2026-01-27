import 'package:flutter/material.dart';
import 'onBoarding_screen.dart'; // Navigate to Onboarding

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to OnboardingScreen after delay (total 4 seconds)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, 0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFF003135), Color(0xFF024950)],
          ),
        ),
        child: Stack(
          children: [
            // Background Decorative Circles
            Positioned(
              left: 35,
              top: 75,
              child: Opacity(
                opacity: 0.22,
                child: Container(
                  width: 137,
                  height: 137,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF284342),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),
             Positioned(
              left: 75,
              top: 75,
              child: Opacity(
                opacity: 0.26,
                child: Container(
                  width: 202,
                  height: 202,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF964734),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 100,
              child: Opacity(
                opacity: 0.22,
                child: Container(
                  width: 137,
                  height: 137,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF2D5C5B),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),
             Positioned(
              left: -50,
              bottom: 100,
              child: Opacity(
                opacity: 0.26,
                child: Container(
                  width: 202,
                  height: 202,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF964734),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      const Text(
                        'FitBite',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                          height: 1.0, 
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      const Text(
                        'Your Personal Diet & Fitness Assistant',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFAFDDE5),
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 200),
                      // Loading Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(const Color(0xFF0FA4AF), 1.0, 12),
                          const SizedBox(width: 5),
                          _buildDot(const Color(0xFF0FA4AF), 0.76, 10),
                          const SizedBox(width: 5),
                          _buildDot(const Color(0xFF0FA4AF), 0.50, 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color, double opacity, double size) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
