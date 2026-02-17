import 'package:firebase_auth/firebase_auth.dart';
import 'base_view_model.dart';
import '../data/models/workout_model.dart';
import '../data/repositories/workout_repository.dart';

import '../data/repositories/user_repository.dart';

/// ViewModel for Workout Plan Screen
class WorkoutViewModel extends BaseViewModel {
  final WorkoutRepository _workoutRepository;
  final UserRepository _userRepository;
  
  WorkoutViewModel({WorkoutRepository? workoutRepository, UserRepository? userRepository})
      : _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _userRepository = userRepository ?? UserRepository();

  int _selectedTab = 0; // 0: Home Workout, 1: Gym Workout
  int _selectedDay = 1; // 1 to 7

  // Note: completedExercises might be better tracked in repository, but keeping local for now is fine for UI
  final Set<int> _completedExercises = {};

  int get selectedTab => _selectedTab;
  int get selectedDay => _selectedDay;
  Set<int> get completedExercises => _completedExercises;
  
  WorkoutPlan? _homeWorkout;
  WorkoutPlan? _gymWorkout;
  
  WorkoutPlan? get currentPlan => _selectedTab == 0 ? _homeWorkout : _gymWorkout;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // List of days labels
  final List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Initialize
  Future<void> init() async {
    await fetchWorkoutPlans();
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
      // 1. Fetch User Profile
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel == null) {
        throw Exception('User profile not found.');
      }
      final userProfile = userModel.toJson();

      // Generate both plans
      final plans = await _workoutRepository.generateAndSaveWorkoutPlans(
        userId: userId!,
        userProfile: userProfile,
      );
      
      _homeWorkout = plans['home'];
      _gymWorkout = plans['gym'];
      
      notifyListeners();
    } catch (e) {
       setError('Failed to generate workouts: $e');
       rethrow; // Rethrow to handle in UI (e.g. Loading Screen)
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

  /// Get total duration of the current workout (Sum of exercises)
  int get durationMinutes {
    // Assuming each exercise takes about 10 mins or we can use a fixed value per exercise
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

  /// Get total calories (alias for consistency with UI)
  int get totalCalories => caloriesBurned;

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
      notifyListeners();
    }
  }

  /// Toggle exercise completion
  void toggleExerciseCompletion(int exerciseId) {
    if (_completedExercises.contains(exerciseId)) {
      _completedExercises.remove(exerciseId);
    } else {
      _completedExercises.add(exerciseId);
    }
    notifyListeners();
  }

  /// Check if an exercise is completed
  bool isExerciseCompleted(int exerciseId) {
    return _completedExercises.contains(exerciseId);
  }
}
