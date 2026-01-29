import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'workout_plan_screen.dart';
import 'diet_screen.dart';
import 'ai_assistant_screen.dart';
import 'progress_tracking_screen.dart';
import 'settings_screen.dart';

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchTab(int index) {
    mainScreenKey.currentState?._onItemTapped(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutPlanScreen(),
    const DietScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mainScreenKey,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0FA4AF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
