import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_assistant_screen.dart';
import 'progress_tracking_screen.dart';
import 'workout_plan_screen.dart';
import 'settings_screen.dart';
import 'diet_screen.dart';
import 'home_screen.dart';
import '../components/animate_in.dart';
import '../../viewmodels/main_view_model.dart';
import '../../viewmodels/diet_view_model.dart';
import '../../viewmodels/workout_view_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchTab(int index) {
    MainViewModel.switchTabStatic(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Screens are stateless/stateful widgets, but we don't manage their state here anymore
  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutPlanScreen(),
    const DietScreen(),
    const SettingsScreen(),
    const ProgressTrackingScreen(),
    const AiAssistantScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Register this instance in ViewModel for static access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainViewModel>().setInstance();
      
      // Initialize data when MainScreen loads
      context.read<DietViewModel>().init();
      context.read<WorkoutViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: _screens[viewModel.selectedIndex],
          bottomNavigationBar: AnimateIn(
            delay: const Duration(milliseconds: 800),
            slideOffset: 30,
            child: BottomNavigationBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
                BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Diet'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
              currentIndex: viewModel.selectedIndex < 4 ? viewModel.selectedIndex : 0,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => viewModel.switchTab(index),
            ),
          ),
        );
      },
    );
  }
}

