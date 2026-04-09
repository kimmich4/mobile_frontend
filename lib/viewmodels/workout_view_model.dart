import '../data/repositories/auth_repository.dart';
import 'base_view_model.dart';
import '../data/models/workout_model.dart';
import '../data/repositories/workout_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/progress_repository.dart';

/// ViewModel for Workout Plan Screen — connects exercise completion to progress tracking
class WorkoutViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final WorkoutRepository _workoutRepository;
  final UserRepository _userRepository;
  final ProgressRepository _progressRepository;

  WorkoutViewModel({
    AuthRepository? authRepository,
    WorkoutRepository? workoutRepository,
    UserRepository? userRepository,
    ProgressRepository? progressRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _progressRepository = progressRepository ?? ProgressRepository();

  int _selectedTab = 0; // 0: Home Workout, 1: Gym Workout
  int _selectedDay = 1; // 1 to 7

  final Map<int, Set<int>> _completedHomeExercises = {};
  final Map<int, Set<int>> _completedGymExercises = {};

  int get selectedTab => _selectedTab;
  int get selectedDay => _selectedDay;
  Set<int> get completedExercises {
    if (_selectedTab == 0) {
      return _completedHomeExercises[_selectedDay] ?? {};
    } else {
      return _completedGymExercises[_selectedDay] ?? {};
    }
  }

  WorkoutPlan? _homeWorkout;
  WorkoutPlan? _gymWorkout;

  WorkoutPlan? get currentPlan => _selectedTab == 0 ? _homeWorkout : _gymWorkout;

  String? get userId => _authRepository.currentUser?.uid;

  // Track if today's workout was already counted toward weekly goal
  bool _todayWorkoutLogged = false;

  final List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Initialize
  Future<void> init() async {
    // Default to today
    _selectedDay = DateTime.now().weekday; // 1=Mon .. 7=Sun
    await fetchWorkoutPlans();
    await _loadCompletedExercises();
  }

  /// Load completed exercises from Firestore
  Future<void> _loadCompletedExercises() async {
    if (userId == null) return;
    try {
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel != null) {
        if (userModel.completedHomeExercises.isNotEmpty) {
          _completedHomeExercises.clear();
          userModel.completedHomeExercises.forEach((dayIndex, exerciseList) {
            _completedHomeExercises[dayIndex] = Set<int>.from(exerciseList);
          });
        }
        if (userModel.completedGymExercises.isNotEmpty) {
          _completedGymExercises.clear();
          userModel.completedGymExercises.forEach((dayIndex, exerciseList) {
            _completedGymExercises[dayIndex] = Set<int>.from(exerciseList);
          });
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Fetch workout plans
  Future<void> fetchWorkoutPlans() async {
    if (userId == null) return;

    setLoading(true);
    clearError();

    try {
      _homeWorkout = await _workoutRepository.getWorkoutPlan(userId!, 'home_workout');
      _gymWorkout = await _workoutRepository.getWorkoutPlan(userId!, 'gym_workout');
      notifyListeners();
    } catch (e) {
      setError('Failed to load workout plans: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Generate plans using user profile from Firestore
  Future<void> generateWorkouts() async {
    if (userId == null) {
      setError('User not logged in');
      return;
    }

    setLoading(true);
    clearError();

    try {
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel == null) {
        throw Exception('User profile not found.');
      }
      final userProfile = userModel.toJson();

      final plans = await _workoutRepository.generateAndSaveWorkoutPlans(
        userId: userId!,
        userProfile: userProfile,
      );

      _homeWorkout = plans['home'];
      _gymWorkout = plans['gym'];

      // Sync workoutsGoalPerWeek to user doc
      final plan = _homeWorkout ?? _gymWorkout;
      if (plan != null) {
        final activeDays = plan.days.where((d) => d.exercises.isNotEmpty).length;
        if (activeDays > 0) {
          await _userRepository.updateFields(userId!, {
            'workoutsGoalPerWeek': activeDays,
          });
        }
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to generate workouts: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get current workout list based on selected tab and day
  List<Exercise> get currentWorkoutExercises {
    if (currentPlan == null) return [];
    try {
      final dayPlan = currentPlan!.days.firstWhere((d) => d.day == _selectedDay);
      return dayPlan.exercises;
    } catch (e) {
      return [];
    }
  }

  /// Get total duration of the current workout
  int get durationMinutes {
    return currentWorkoutExercises.length * 8;
  }

  /// Get total calories burned for the selected day
  int get caloriesBurned {
    return currentWorkoutExercises.fold(0, (sum, ex) => sum + ex.calories);
  }

  /// Get total number of exercises for selected day
  int get exerciseCount {
    return currentWorkoutExercises.length;
  }

  /// Get workout title
  String get workoutTitle {
    return currentPlan?.title ?? (_selectedTab == 0 ? 'Home Workout' : 'Gym Workout');
  }

  /// Get total calories (alias)
  int get totalCalories => caloriesBurned;

  /// Check if all exercises for today are completed
  bool get allExercisesCompleted {
    final exercises = currentWorkoutExercises;
    if (exercises.isEmpty) return false;
    final targetMap = _selectedTab == 0 ? _completedHomeExercises : _completedGymExercises;
    return exercises.every((ex) => (targetMap[_selectedDay] ?? {}).contains(ex.id));
  }

  /// Switch between Home and Gym workouts
  void setSelectedTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }

  /// Switch between days
  void setSelectedDay(int day) {
    if (_selectedDay != day) {
      _selectedDay = day;
      // Do not clear _completedExercises here so state isn't lost when switching days
      // _completedExercises.clear();
      _todayWorkoutLogged = false;
      notifyListeners();
    }
  }

  /// Toggle exercise completion and persist to progress tracking
  Future<void> toggleExerciseCompletion(int exerciseId) async {
    final targetMap = _selectedTab == 0 ? _completedHomeExercises : _completedGymExercises;
    
    targetMap[_selectedDay] ??= {};
    if (targetMap[_selectedDay]!.contains(exerciseId)) {
      targetMap[_selectedDay]!.remove(exerciseId);
    } else {
      targetMap[_selectedDay]!.add(exerciseId);
    }
    notifyListeners();

    // Persist to user profile
    if (userId != null) {
      try {
        final updatedExercisesMap = targetMap.map((key, value) => MapEntry(key.toString(), value.toList()));
        final fieldName = _selectedTab == 0 ? 'completedHomeExercises' : 'completedGymExercises';
        
        await _userRepository.updateFields(userId!, {
          fieldName: updatedExercisesMap,
        });
      } catch (e) {
        print('Error persisting exercise completion: $e');
      }
    }

    // If all exercises completed for today → log workout completion
    final todayDay = DateTime.now().weekday;
    if (_selectedDay == todayDay && userId != null) {
      try {
        final dayName = dayLabels[_selectedDay - 1];
        final totalBurned = _calculateCaloriesBurnedForDay(_selectedDay);
        final workoutCompleted = _isWorkoutDayCompleted(_selectedDay);

        _todayWorkoutLogged = workoutCompleted;

        await _progressRepository.logWorkoutCompletion(
          userId!,
          dayName,
          workoutCompleted,
          caloriesBurned: totalBurned,
        );

        final userModel = await _userRepository.getUserProfile(userId!);
        if (userModel != null) {
          await _userRepository.updateFields(userId!, {
            'workoutsCompletedThisWeek': _calculateCompletedWorkoutDays(userModel),
          });
        }
      } catch (e) {
        print('Error logging workout completion: $e');
      }
    }
  }

  /// Check if an exercise is completed
  bool isExerciseCompleted(int exerciseId) {
    final targetMap = _selectedTab == 0 ? _completedHomeExercises : _completedGymExercises;
    return (targetMap[_selectedDay] ?? {}).contains(exerciseId);
  }

  int _calculateCaloriesBurnedForDay(int day) {
    int total = 0;

    if (_homeWorkout != null) {
      try {
        final dayPlan = _homeWorkout!.days.firstWhere((d) => d.day == day);
        final completedHome = _completedHomeExercises[day] ?? {};
        for (final ex in dayPlan.exercises) {
          if (completedHome.contains(ex.id)) {
            total += ex.calories;
          }
        }
      } catch (_) {}
    }

    if (_gymWorkout != null) {
      try {
        final dayPlan = _gymWorkout!.days.firstWhere((d) => d.day == day);
        final completedGym = _completedGymExercises[day] ?? {};
        for (final ex in dayPlan.exercises) {
          if (completedGym.contains(ex.id)) {
            total += ex.calories;
          }
        }
      } catch (_) {}
    }

    return total;
  }

  bool _isWorkoutDayCompleted(int day) {
    bool homeDone = false;
    bool gymDone = false;

    if (_homeWorkout != null) {
      try {
        final dayPlan = _homeWorkout!.days.firstWhere((d) => d.day == day);
        final completedHome = _completedHomeExercises[day] ?? {};
        homeDone =
            dayPlan.exercises.isNotEmpty &&
            dayPlan.exercises.every((ex) => completedHome.contains(ex.id));
      } catch (_) {}
    }

    if (_gymWorkout != null) {
      try {
        final dayPlan = _gymWorkout!.days.firstWhere((d) => d.day == day);
        final completedGym = _completedGymExercises[day] ?? {};
        gymDone =
            dayPlan.exercises.isNotEmpty &&
            dayPlan.exercises.every((ex) => completedGym.contains(ex.id));
      } catch (_) {}
    }

    return homeDone || gymDone;
  }

  int _calculateCompletedWorkoutDays(dynamic userModel) {
    int total = 0;

    for (int day = 1; day <= 7; day++) {
      final completedHome =
          Set<int>.from(userModel.completedHomeExercises[day] ?? const []);
      final completedGym =
          Set<int>.from(userModel.completedGymExercises[day] ?? const []);

      bool homeDone = false;
      bool gymDone = false;

      if (_homeWorkout != null) {
        try {
          final dayPlan = _homeWorkout!.days.firstWhere((d) => d.day == day);
          homeDone =
              dayPlan.exercises.isNotEmpty &&
              dayPlan.exercises.every((ex) => completedHome.contains(ex.id));
        } catch (_) {}
      }

      if (_gymWorkout != null) {
        try {
          final dayPlan = _gymWorkout!.days.firstWhere((d) => d.day == day);
          gymDone =
              dayPlan.exercises.isNotEmpty &&
              dayPlan.exercises.every((ex) => completedGym.contains(ex.id));
        } catch (_) {}
      }

      if (homeDone || gymDone) {
        total++;
      }
    }

    return total;
  }
}
