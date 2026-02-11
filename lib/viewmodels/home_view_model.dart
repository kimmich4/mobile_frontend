import 'dart:async';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// ViewModel for Home Screen
class HomeViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  StreamSubscription<UserModel?>? _userSubscription;

  UserModel? _currentUser;

  // User stats displayed at top (derived from _currentUser)
  String get caloriesConsumed => _currentUser?.currentCalories?.toString() ?? '0';
  String get caloriesGoal => _currentUser?.dailyCalorieGoal?.toString() ?? '2,200';
  String get workoutsCompleted => _currentUser?.workoutsCompletedThisWeek?.toString() ?? '0';
  String get workoutsGoal => _currentUser?.workoutsGoalPerWeek?.toString() ?? '5';
  int get currentStreak => _currentUser?.currentStreak ?? 0;
  String get fullName => _currentUser?.fullName ?? 'User';
  String get profileInitial => _currentUser?.profileInitial ?? 'U';

  // Diet plan info
  final int mealsRemaining = 4; // This could also be fetched from another repo
  double get dietProgress => (_currentUser?.calorieConsumptionPercentage ?? 0.0).clamp(0.0, 1.0);

  // Workout info (Hardcoded for now, can be refactored later)
  final String workoutTitle = 'Workout Plan';
  final String workoutDescription = 'Upper Body - 45 min';

  // Progress summary
  final String weightChange = '-1.2kg';
  final String dietPlanCompletion = '92%';
  final String workoutCompletion = '80%';

  // Daily tip
  final String dailyTip = 'Stay hydrated! Aim for at least 8 glasses of water today.';

  HomeViewModel() {
    _initUserStream();
  }

  void _initUserStream() {
    final user = _authRepository.currentUser;
    if (user != null) {
      _userSubscription = _userRepository.getUserStream(user.uid).listen((userModel) {
        _currentUser = userModel;
        notifyListeners();
      });
    }
  }

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
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
