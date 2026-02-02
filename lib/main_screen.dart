import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'workout_plan_screen.dart';
import 'diet_screen.dart';
import 'ai_assistant_screen.dart';
import 'progress_tracking_screen.dart';
import 'settings_screen.dart';
import 'animate_in.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchTab(int index) {
    _MainScreenState._instance?._onItemTapped(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static _MainScreenState? _instance;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    if (_instance == this) _instance = null;
    super.dispose();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutPlanScreen(),
    const DietScreen(),
    const SettingsScreen(),
    const ProgressTrackingScreen(),
    const AiAssistantScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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
          currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
