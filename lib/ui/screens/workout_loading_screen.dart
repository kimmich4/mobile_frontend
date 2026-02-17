import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/workout_view_model.dart';
import '../../viewmodels/diet_view_model.dart';
import 'main_screen.dart';
import '../components/animate_in.dart';

class WorkoutLoadingScreen extends StatefulWidget {
  const WorkoutLoadingScreen({super.key});

  @override
  State<WorkoutLoadingScreen> createState() => _WorkoutLoadingScreenState();
}

class _WorkoutLoadingScreenState extends State<WorkoutLoadingScreen> {
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWorkout();
    });
  }

  Future<void> _generateWorkout() async {
    final workoutViewModel = context.read<WorkoutViewModel>();
    final dietViewModel = context.read<DietViewModel>();
    
    setState(() {
      _hasError = false;
      _errorMsg = '';
    });

    try {
      print('DEBUG: Starting dual AI generation...');
      
      // 2. Trigger both generations in parallel
      await Future.wait([
        workoutViewModel.generateWorkouts(),
        dietViewModel.generateDietPlan(),
      ]);
      
      print('DEBUG: Generation completed successfully!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      print('DEBUG: Generation failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMsg = e.toString().contains('500') 
              ? 'Server Error (500). The AI is currently unavailable. Please try again or skip to the dashboard.' 
              : 'Connection Error. Please check your internet and try again.';
        });
      }
    }
  }

  void _skipToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003135),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AnimateIn(
                child: Icon(Icons.fitness_center, size: 80, color: Color(0xFF0FA4AF)),
              ),
              const SizedBox(height: 32),
              const AnimateIn(
                delay: Duration(milliseconds: 200),
                child: Text(
                  'Creating Your Personal Workout Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AnimateIn(
                delay: Duration(milliseconds: 400),
                child: Text(
                  'Our AI is designing the perfect routine for your goals and health conditions...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFAFDDE5),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (!_hasError) ...[
                const CircularProgressIndicator(
                  color: Color(0xFF0FA4AF),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  'This may take a minute',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMsg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _generateWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0FA4AF),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Retry Generation', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: _skipToDashboard,
                  child: const Text('Skip to Dashboard', style: TextStyle(color: Color(0xFFAFDDE5))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
