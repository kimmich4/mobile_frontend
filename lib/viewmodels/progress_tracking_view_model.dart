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

/// ViewModel for Progress Tracking Screen — computes real progress data.
/// Reads weight logs and daily logs from Firebase for each period.
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
    _initAuthListener();
  }

  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  int get selectedPeriod => _selectedPeriod;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Current period enum
  ProgressPeriod get currentPeriod {
    switch (_selectedPeriod) {
      case 0:  return ProgressPeriod.week;
      case 1:  return ProgressPeriod.month;
      case 2:  return ProgressPeriod.year;
      default: return ProgressPeriod.week;
    }
  }

  // ── State ──────────────────────────────────────────────────────────────

  ProgressStats? _stats;
  ProgressStats? get stats => _stats;

  UserModel? _currentUser;
  DietPlan? _dietPlan;
  WorkoutPlan? _homeWorkout;
  WorkoutPlan? _gymWorkout;

  // Weight chart — real daily logs from Firebase
  final List<WeightDataPoint> weightData = [];

  // Calories chart — real Firebase dailyLogs, period-aware
  final List<CalorieDataPoint> caloriesData = [];

  // Consistency (weekly workout streak)
  ConsistencyData _consistencyData = ConsistencyData(days: []);
  ConsistencyData get consistencyData => _consistencyData;

  // Whether a weight save is in progress (for Progress screen log-weight card)
  bool _isSavingWeight = false;
  bool get isSavingWeight => _isSavingWeight;

  // ── Computed getters ────────────────────────────────────────────────────

  /// Subtitle for weight chart — shows period delta from real stats
  String get weightProgressSubtitle {
    if (_stats == null) return '';
    final lost = _stats!.weightLostKg;
    final direction = _stats!.weightLostPeriod.contains('gained') ? '+' : '-';
    if (lost == 0) return 'No change this ${currentPeriod.displayName.toLowerCase()}';
    return '$direction${lost.toStringAsFixed(1)} kg ${currentPeriod.displayName.toLowerCase()}';
  }

  /// Most recent weight logged in the Progress screen (new field, separate)
  double? get latestTrackedWeight => _currentUser?.trackedWeightKg;

  /// Original signup weight (unchanged)
  double? get signupWeight => _currentUser?.weightKg;

  /// Subtitle for workout consistency section
  String get consistencySubtitle {
    final completed = _consistencyData.days.where((d) => d.isCompleted).length;
    final total = _consistencyData.days.length;
    if (total == 0) return 'No data yet';
    final rate = _consistencyData.completionRate;
    return '$completed/$total days · ${(rate * 100).round()}% completion';
  }

  String get goalEstimate => _stats?.toGoalTime ?? '';

  // ── Auth + stream setup ─────────────────────────────────────────────────

  void _initAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _userSubscription?.cancel();
      _currentUser = null;

      if (user != null) {
        _userSubscription = _userRepository.getUserStream(user.uid).listen((userModel) {
          _currentUser = userModel;
          _recomputeProgress();
        });
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

  Future<void> _loadPlans(String uid) async {
    try {
      _dietPlan = await _dietRepository.getDietPlan(uid);
      _homeWorkout = await _workoutRepository.getWorkoutPlan(uid, 'home_workout');
      _gymWorkout = await _workoutRepository.getWorkoutPlan(uid, 'gym_workout');
      _recomputeProgress();
    } catch (_) {}
  }

  // ── Core recompute — now fully Firebase-backed and period-aware ──────────

  Future<void> _recomputeProgress() async {
    if (_currentUser == null || userId == null) return;

    try {
      // 1. Compute period-aware stats from Firebase
      _stats = await _progressRepository.computeProgressStats(
        userId!,
        _currentUser!,
        currentPeriod,
        dietPlan: _dietPlan,
        homeWorkout: _homeWorkout,
        gymWorkout: _gymWorkout,
      );

      // 2. Persist snapshot to Firebase
      await _progressRepository.updateProgressStats(userId!, _stats!);

      // 3. Weight chart — real daily logs from Firebase (period-aware)
      weightData.clear();
      weightData.addAll(
        await _progressRepository.fetchWeightLogsForPeriod(userId!, currentPeriod),
      );

      // 4. Calorie chart — real Firebase dailyLogs (period-aware)
      caloriesData.clear();
      caloriesData.addAll(
        await _progressRepository.fetchCaloriesForPeriod(userId!, currentPeriod),
      );

      // 5. Save today's calorie data to dailyLogs (only for current week)
      if (currentPeriod == ProgressPeriod.week) {
        await _saveTodayCaloriesToFirebase();
      }

      // 6. Build workout consistency from user doc (weekly)
      _buildConsistencyFromUserData();

      if (!_initialized) _initialized = true;
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  /// Saves today's calorie data based on completed exercises/meals (week view only)
  Future<void> _saveTodayCaloriesToFirebase() async {
    if (userId == null || _currentUser == null) return;
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T').first;
      final todayWeekday = today.weekday; // 1=Mon..7=Sun

      // Burned from completed exercises today
      int burned = 0;
      if (_homeWorkout != null) {
        final completedHome = _currentUser!.completedHomeExercises[todayWeekday] ?? [];
        try {
          final dayPlan = _homeWorkout!.days.firstWhere((d) => d.day == todayWeekday);
          for (final ex in dayPlan.exercises) {
            if (completedHome.contains(ex.id)) burned += ex.calories;
          }
        } catch (_) {}
      }
      if (_gymWorkout != null) {
        final completedGym = _currentUser!.completedGymExercises[todayWeekday] ?? [];
        try {
          final dayPlan = _gymWorkout!.days.firstWhere((d) => d.day == todayWeekday);
          for (final ex in dayPlan.exercises) {
            if (completedGym.contains(ex.id)) burned += ex.calories;
          }
        } catch (_) {}
      }

      // Consumed from completed meals today (diet plan uses 0-based day index)
      int consumed = 0;
      if (_dietPlan != null) {
        final completedMealIndices = _currentUser!.completedMeals[todayWeekday - 1] ?? [];
        try {
          final dayDiet = _dietPlan!.days.firstWhere((d) => d.day == todayWeekday);
          for (int i = 0; i < dayDiet.meals.length; i++) {
            if (completedMealIndices.contains(i)) consumed += dayDiet.meals[i].totalCalories;
          }
        } catch (_) {}
      }

      // Whether any workout was done today
      final hasHomeWorkout = _currentUser!.completedHomeExercises[todayWeekday]?.isNotEmpty ?? false;
      final hasGymWorkout = _currentUser!.completedGymExercises[todayWeekday]?.isNotEmpty ?? false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .collection('dailyLogs')
          .doc(todayStr)
          .set({
        'caloriesBurned': burned,
        'caloriesConsumed': consumed,
        'workoutCompleted': hasHomeWorkout || hasGymWorkout,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Build consistency data from user doc (weekly exercise completions)
  void _buildConsistencyFromUserData() {
    if (_currentUser == null) return;
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final List<WorkoutDayStatus> days = [];
    for (int i = 0; i < 7; i++) {
      final dayNumber = i + 1;
      bool isCompleted = false;

      final homeCompleted = _currentUser!.completedHomeExercises[dayNumber]?.isNotEmpty ?? false;
      final gymCompleted = _currentUser!.completedGymExercises[dayNumber]?.isNotEmpty ?? false;

      if (homeCompleted || gymCompleted) {
        bool allHomeDone = true;
        bool allGymDone = true;

        if (_homeWorkout != null) {
          try {
            final dayPlan = _homeWorkout!.days.firstWhere((d) => d.day == dayNumber);
            final completedIds = _currentUser!.completedHomeExercises[dayNumber] ?? [];
            allHomeDone = dayPlan.exercises.every((ex) => completedIds.contains(ex.id));
          } catch (_) {
            allHomeDone = true;
          }
        }

        if (_gymWorkout != null) {
          try {
            final dayPlan = _gymWorkout!.days.firstWhere((d) => d.day == dayNumber);
            final completedIds = _currentUser!.completedGymExercises[dayNumber] ?? [];
            allGymDone = dayPlan.exercises.every((ex) => completedIds.contains(ex.id));
          } catch (_) {
            allGymDone = true;
          }
        }

        isCompleted = allHomeDone || allGymDone;
      }

      days.add(WorkoutDayStatus(dayName: dayLabels[i], isCompleted: isCompleted));
    }

    _consistencyData = ConsistencyData(days: days);
  }

  // ── Public API ──────────────────────────────────────────────────────────

  Future<void> init() async {
    if (!_initialized) {
      await fetchProgressData();
    }
  }

  Future<void> fetchProgressData() async {
    if (userId == null) return;

    setLoading(true);
    clearError();

    try {
      _currentUser = await _userRepository.getUserProfile(userId!);
      if (_currentUser == null) {
        setLoading(false);
        return;
      }
      _dietPlan = await _dietRepository.getDietPlan(userId!);
      _homeWorkout = await _workoutRepository.getWorkoutPlan(userId!, 'home_workout');
      _gymWorkout = await _workoutRepository.getWorkoutPlan(userId!, 'gym_workout');

      await _recomputeProgress();
    } catch (e) {
      setError('Failed to load progress data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Switch period and immediately reload all data from Firebase
  void setSelectedPeriod(int period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners(); // show loading immediately
    fetchProgressData();
  }

  /// Log a new weight entry from the Progress Tracking screen.
  /// Saves `trackedWeightKg` to the user doc AND appends to `weightLogs`.
  /// Does NOT touch existing `weightKg` or `currentWeightKg` fields.
  Future<void> logNewWeight(double newWeight) async {
    if (userId == null) return;
    _isSavingWeight = true;
    notifyListeners();
    try {
      // 1. Update user document
      await _userRepository.updateFields(userId!, {'trackedWeightKg': newWeight});

      // 2. Append to weightLogs history
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .collection('weightLogs')
          .add({
        'trackedWeightKg': newWeight,
        'loggedAt': FieldValue.serverTimestamp(),
      });

      // 3. Optimistic local update + recompute
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(trackedWeightKg: newWeight);
        await _recomputeProgress();
      }
    } catch (e) {
      setError('Failed to save weight: $e');
    } finally {
      _isSavingWeight = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
