import 'base_view_model.dart';

/// ViewModel for Home Screen
class HomeViewModel extends BaseViewModel {
  // User stats displayed at top
  final String caloriesConsumed = '1,847';
  final String caloriesGoal = '2,200';
  final String workoutsCompleted = '4';
  final String workoutsGoal = '5';
  final int currentStreak = 12;

  // Diet plan info
  final int mealsRemaining = 4;
  final double dietProgress = 0.8; // 80% of daily calories

  // Workout info
  final String workoutTitle = 'Workout Plan';
  final String workoutDescription = 'Upper Body - 45 min';

  // Progress summary
  final String weightChange = '-1.2kg';
  final String dietPlanCompletion = '92%';
  final String workoutCompletion = '80%';

  // Daily tip
  final String dailyTip = 'Stay hydrated! Aim for at least 8 glasses of water today.';

  /// Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Navigate to specific tab
  void navigateToTab(int tabIndex) {
    // This would call MainViewModel.switchTabStatic
    // Implemented in the view layer
    notifyListeners();
  }
}
