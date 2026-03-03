import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'base_view_model.dart';
import '../data/models/progress_model.dart';
import '../data/models/user_model.dart';
import '../data/models/diet_model.dart';
import '../data/models/workout_model.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/diet_repository.dart';
import '../data/repositories/workout_repository.dart';

/// ViewModel for Progress Tracking Screen — computes real progress data
/// Uses real-time user stream so data updates automatically when user
/// completes exercises or meals.
class ProgressTrackingViewModel extends BaseViewModel {
  final ProgressRepository _progressRepository;
  final UserRepository _userRepository;
  final DietRepository _dietRepository;
  final WorkoutRepository _workoutRepository;

  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _initialized = false;

  ProgressTrackingViewModel({
    ProgressRepository? progressRepository,
    UserRepository? userRepository,
    DietRepository? dietRepository,
    WorkoutRepository? workoutRepository,
  })  : _progressRepository = progressRepository ?? ProgressRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _dietRepository = dietRepository ?? DietRepository(),
        _workoutRepository = workoutRepository ?? WorkoutRepository() {
    // Auto-initialize with auth listener
    _initAuthListener();
  }

  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  int get selectedPeriod => _selectedPeriod;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Get current period type
  ProgressPeriod get currentPeriod {
    switch (_selectedPeriod) {
      case 0:
        return ProgressPeriod.week;
      case 1:
        return ProgressPeriod.month;
      case 2:
        return ProgressPeriod.year;
      default:
        return ProgressPeriod.week;
    }
  }

  // Stats data
  ProgressStats? _stats;
  ProgressStats? get stats => _stats;

  // User data for computing dynamic subtitles
  UserModel? _currentUser;

  // Plans for calorie computation
  DietPlan? _dietPlan;
  WorkoutPlan? _homeWorkout;
  WorkoutPlan? _gymWorkout;

  // Weight progress data
  final List<WeightDataPoint> weightData = [];

  // Calories data
  final List<CalorieDataPoint> caloriesData = [];

  // Consistency data
  ConsistencyData _consistencyData = ConsistencyData(days: []);
  ConsistencyData get consistencyData => _consistencyData;

  /// Dynamic subtitle for weight progress
  String get weightProgressSubtitle {
    if (_currentUser == null) return '';
    final initial = _currentUser!.weightKg;
    final current = _currentUser!.currentWeightKg;
    if (initial != null && current != null) {
      final diff = current - initial;
      final sign = diff >= 0 ? '+' : '';
      final periodLabel = currentPeriod.displayName.toLowerCase();
      return '$sign${diff.toStringAsFixed(1)} kg this $periodLabel';
    }
    return 'No weight data yet';
  }

  /// Dynamic subtitle for workout consistency
  String get consistencySubtitle {
    final completed = _consistencyData.days.where((d) => d.isCompleted).length;
    final total = _consistencyData.days.length;
    if (total == 0) return 'No data yet';
    final rate = _consistencyData.completionRate;
    return '$completed/$total days · ${(rate * 100).round()}% completion';
  }

  /// Goal estimate display
  String get goalEstimate {
    if (_stats == null) return '';
    return _stats!.toGoalTime;
  }

  /// Auto-initialize by listening to auth state
  void _initAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _userSubscription?.cancel();
      _currentUser = null;

      if (user != null) {
        // Listen to user doc for real-time updates
        _userSubscription = _userRepository.getUserStream(user.uid).listen((userModel) {
          _currentUser = userModel;
          // Recompute progress whenever user data changes
          _recomputeProgress();
        });
        // Fetch plans once
        _loadPlans(user.uid);
      } else {
        _stats = null;
        weightData.clear();
        caloriesData.clear();
        _consistencyData = ConsistencyData(days: []);
        notifyListeners();
      }
    });
  }

  /// Load workout and diet plans
  Future<void> _loadPlans(String uid) async {
    try {
      _dietPlan = await _dietRepository.getDietPlan(uid);
      _homeWorkout = await _workoutRepository.getWorkoutPlan(uid, 'home_workout');
      _gymWorkout = await _workoutRepository.getWorkoutPlan(uid, 'gym_workout');
      // Recompute after plans loaded
      _recomputeProgress();
    } catch (e) {
      // Plans not available yet — will show empty state
    }
  }

  /// Recompute all progress data from current user + plans
  Future<void> _recomputeProgress() async {
    if (_currentUser == null || userId == null) return;

    try {
      // 1. Compute stats dynamically from real data
      _stats = await _progressRepository.computeProgressStats(
        userId!,
        _currentUser!,
        dietPlan: _dietPlan,
        homeWorkout: _homeWorkout,
        gymWorkout: _gymWorkout,
      );

      // 2. Save computed stats to Firebase for persistence
      await _progressRepository.updateProgressStats(userId!, _stats!);

      // 3. Populate weight chart data from user profile
      weightData.clear();
      weightData.addAll(_progressRepository.getWeightChartData(_currentUser!));

      // 4. Populate calorie chart data from completed meals/exercises
      caloriesData.clear();
      caloriesData.addAll(_progressRepository.getWeeklyCaloriesData(
        _currentUser!,
        dietPlan: _dietPlan,
        homeWorkout: _homeWorkout,
        gymWorkout: _gymWorkout,
      ));

      // 5. Save daily calorie data to Firebase for history
      await _saveDailyCaloriesToFirebase();

      // 6. Build consistency from actual user doc data (not just dailyLogs)
      _buildConsistencyFromUserData();

      if (!_initialized) _initialized = true;
      notifyListeners();
    } catch (e) {
      // Don't set error during background recomputation
      // Just notify with what we have
      notifyListeners();
    }
  }

  /// Save all 7 days of weekly calorie summaries to Firebase dailyLogs
  Future<void> _saveDailyCaloriesToFirebase() async {
    if (userId == null) return;
    try {
      final now = DateTime.now();
      // Calculate Monday of the current week
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      // Iterate through all 7 days of the current week
      for (int i = 0; i < 7; i++) {
        final currentDayDate = monday.add(Duration(days: i));
        final dateString = currentDayDate.toIso8601String().split('T').first;
        final dayLabel = dayLabels[i];

        // Find data for this specific day
        CalorieDataPoint? dayData;
        for (final point in caloriesData) {
          if (point.day == dayLabel) {
            dayData = point;
            break;
          }
        }

        if (dayData != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId!)
              .collection('dailyLogs')
              .doc(dateString)
              .set({
            'caloriesBurned': dayData.burned,
            'caloriesConsumed': dayData.consumed,
            'dayName': dayLabel, // Added for consistency
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (_) {
      // Non-critical — don't block the UI
    }
  }

  /// Build consistency data from the actual user doc (completedExercises)
  /// instead of relying only on dailyLogs
  void _buildConsistencyFromUserData() {
    if (_currentUser == null) return;

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayWeekday = DateTime.now().weekday; // 1=Mon..7=Sun

    final List<WorkoutDayStatus> days = [];
    for (int i = 0; i < 7; i++) {
      final dayNumber = i + 1;
      bool isCompleted = false;

      // Check all days for completions (past, present, or future entries)
      final homeCompleted = _currentUser!.completedHomeExercises[dayNumber]?.isNotEmpty ?? false;
      final gymCompleted = _currentUser!.completedGymExercises[dayNumber]?.isNotEmpty ?? false;

      // Also check if ALL exercises for the day are done (true completion)
      if (homeCompleted || gymCompleted) {
        bool allHomeDone = true;
        bool allGymDone = true;

        if (_homeWorkout != null) {
          try {
            final dayPlan = _homeWorkout!.days.firstWhere((d) => d.day == dayNumber);
            final completedIds = _currentUser!.completedHomeExercises[dayNumber] ?? [];
            allHomeDone = dayPlan.exercises.every((ex) => completedIds.contains(ex.id));
          } catch (_) {
            allHomeDone = true; // No plan for this day = consider done
          }
        }

        if (_gymWorkout != null) {
          try {
            final dayPlan = _gymWorkout!.days.firstWhere((d) => d.day == dayNumber);
            final completedIds = _currentUser!.completedGymExercises[dayNumber] ?? [];
            allGymDone = dayPlan.exercises.every((ex) => completedIds.contains(ex.id));
          } catch (_) {
            allGymDone = true; // No plan for this day = consider done
          }
        }

        // Mark completed if ALL exercises in at least one plan type are done
        isCompleted = allHomeDone || allGymDone;
      }

      days.add(WorkoutDayStatus(dayName: dayLabels[i], isCompleted: isCompleted));
    }

    _consistencyData = ConsistencyData(days: days);
  }

  /// Initialize — called when screen is first displayed
  Future<void> init() async {
    if (!_initialized) {
      await fetchProgressData();
    }
  }

  /// Fetch all progress data (manual refresh)
  Future<void> fetchProgressData() async {
    if (userId == null) return;

    setLoading(true);
    clearError();

    try {
      // Fetch user profile
      _currentUser = await _userRepository.getUserProfile(userId!);
      if (_currentUser == null) {
        setLoading(false);
        return;
      }

      // Fetch plans
      _dietPlan = await _dietRepository.getDietPlan(userId!);
      _homeWorkout = await _workoutRepository.getWorkoutPlan(userId!, 'home_workout');
      _gymWorkout = await _workoutRepository.getWorkoutPlan(userId!, 'gym_workout');

      // Recompute everything
      await _recomputeProgress();
    } catch (e) {
      setError('Failed to load progress data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Set selected period and re-fetch data
  void setSelectedPeriod(int period) {
    _selectedPeriod = period;
    notifyListeners();
    fetchProgressData();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
