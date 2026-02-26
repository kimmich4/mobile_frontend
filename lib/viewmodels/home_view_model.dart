import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/models/diet_model.dart';
import '../data/models/workout_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/diet_repository.dart';
import '../data/repositories/workout_repository.dart';
import 'base_view_model.dart';

/// ViewModel for Home Screen — pulls real data from AI-generated plans
class HomeViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  final DietRepository _dietRepository = DietRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  UserModel? _currentUser;
  DietPlan? _dietPlan;
  WorkoutPlan? _homeWorkout;
  WorkoutPlan? _gymWorkout;

  // ── User info ──
  String get fullName => _currentUser?.fullName ?? 'User';
  String get profileInitial => _currentUser?.profileInitial ?? 'U';
  String? get profilePicturePath => _currentUser?.profilePicturePath;

  // ── Calories (from diet plan for today) ──
  String get caloriesConsumed =>
      _currentUser?.currentCalories?.toString() ?? '0';

  String get caloriesGoal {
    final todayPlan = _todayDietPlan;
    if (todayPlan != null && todayPlan.totalCalories > 0) {
      return todayPlan.totalCalories.toString();
    }
    return _currentUser?.dailyCalorieGoal?.toString() ?? '2,200';
  }

  // ── Workouts (from workout plans) ──
  String get workoutsCompleted =>
      _currentUser?.workoutsCompletedThisWeek?.toString() ?? '0';

  /// Goal = number of days in workout plan that have exercises (not rest days)
  String get workoutsGoal {
    final plan = _homeWorkout ?? _gymWorkout;
    if (plan != null && plan.days.isNotEmpty) {
      final activeDays = plan.days.where((d) => d.exercises.isNotEmpty).length;
      return activeDays > 0 ? activeDays.toString() : '5';
    }
    return _currentUser?.workoutsGoalPerWeek?.toString() ?? '5';
  }

  int get currentStreak => _currentUser?.currentStreak ?? 0;

  // ── Diet plan info ──
  int get mealsRemaining {
    final todayPlan = _todayDietPlan;
    if (todayPlan == null) return 0;
    final totalMeals = todayPlan.meals.length;
    final consumed = _currentUser?.completedMeals[_todayWeekday - 1]?.length ?? 0;
    return (totalMeals - consumed).clamp(0, totalMeals);
  }

  double get dietProgress {
    final todayPlan = _todayDietPlan;
    if (todayPlan == null || todayPlan.totalCalories == 0) return 0.0;
    final consumed = _currentUser?.currentCalories ?? 0;
    return (consumed / todayPlan.totalCalories).clamp(0.0, 1.0);
  }

  // ── Workout info (dynamic) ──
  String get workoutTitle {
    if (_homeWorkout != null) return _homeWorkout!.title;
    if (_gymWorkout != null) return _gymWorkout!.title;
    return 'Workout Plan';
  }

  String get workoutDescription {
    final plan = _homeWorkout ?? _gymWorkout;
    if (plan == null) return 'No plan yet';
    final todayDay = _todayWeekday;
    try {
      final dayPlan = plan.days.firstWhere((d) => d.day == todayDay);
      final count = dayPlan.exercises.length;
      final duration = count * 8; // ~8 min per exercise estimate
      return '$count exercises · ~$duration min';
    } catch (_) {
      return '${plan.exerciseCount} total exercises';
    }
  }

  // ── Progress summary (computed) ──
  String get weightChange {
    final initial = _currentUser?.weightKg;
    final current = _currentUser?.currentWeightKg;
    if (initial != null && current != null) {
      final diff = current - initial;
      final sign = diff >= 0 ? '+' : '';
      return '${sign}${diff.toStringAsFixed(1)}kg';
    }
    return '0.0kg';
  }

  String get dietPlanCompletion {
    final todayPlan = _todayDietPlan;
    if (todayPlan == null || todayPlan.meals.isEmpty) return '0%';
    final completed = _currentUser?.completedMeals[_todayWeekday - 1]?.length ?? 0;
    final pct = (completed / todayPlan.meals.length * 100).round();
    return '$pct%';
  }

  String get workoutCompletion {
    final completed = _currentUser?.workoutsCompletedThisWeek ?? 0;
    final goal = int.tryParse(workoutsGoal) ?? 5;
    if (goal == 0) return '0%';
    final pct = (completed / goal * 100).round().clamp(0, 100);
    return '$pct%';
  }

  // ── Daily tip ──
  final String dailyTip =
      'Stay hydrated! Aim for at least 8 glasses of water today.';

  // ── Helpers ──
  int get _todayWeekday => DateTime.now().weekday; // 1=Mon .. 7=Sun

  DailyDietPlan? get _todayDietPlan {
    if (_dietPlan == null || _dietPlan!.days.isEmpty) return null;
    try {
      return _dietPlan!.days.firstWhere((d) => d.day == _todayWeekday);
    } catch (_) {
      return _dietPlan!.days.isNotEmpty ? _dietPlan!.days.first : null;
    }
  }

  // ── Lifecycle ──
  HomeViewModel() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      _userSubscription?.cancel();
      _currentUser = null;

      if (user != null) {
        // Listen to user doc for real-time updates
        _userSubscription =
            _userRepository.getUserStream(user.uid).listen((userModel) {
          _currentUser = userModel;
          notifyListeners();
        });
        // Fetch plans once
        _loadPlans(user.uid);
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> _loadPlans(String userId) async {
    try {
      _dietPlan = await _dietRepository.getDietPlan(userId);
      _homeWorkout =
          await _workoutRepository.getWorkoutPlan(userId, 'home_workout');
      _gymWorkout =
          await _workoutRepository.getWorkoutPlan(userId, 'gym_workout');
      notifyListeners();
    } catch (e) {
      print('HomeViewModel: Error loading plans: $e');
    }
  }

  /// Reload plans (e.g. after generating new ones)
  Future<void> refreshPlans() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _loadPlans(uid);
  }

  /// Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
