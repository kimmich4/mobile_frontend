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
  // Note: completedExercises might be better tracked in repository, but keeping local for now is fine for UI
  final Set<int> _completedExercises = {};

  int get selectedTab => _selectedTab;
  Set<int> get completedExercises => _completedExercises;
  
  WorkoutPlan? _homeWorkout;
  WorkoutPlan? _gymWorkout;
  
  WorkoutPlan? get currentPlan => _selectedTab == 0 ? _homeWorkout : _gymWorkout;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Calendar days - This would likely come from ProgressRepository in real implementation
  // For now keeping it simple or can pull from progress
  final List<WorkoutCalendarDay> calendarDays = [
    WorkoutCalendarDay(dayName: 'Mon', isCompleted: true),
    WorkoutCalendarDay(dayName: 'Tue', isCompleted: true),
    WorkoutCalendarDay(dayName: 'Wed', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Thu', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Fri', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Sat', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Sun', isCompleted: false),
  ];

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
      // In a real app we might distinguish 'Home' vs 'Gym' plans 
      // by ID or type. Here we'll try to fetch 'home_workout' and 'gym_workout' 
      // or similar IDs, or just fetch all and filter.
      // For demonstration, let's assume specific IDs or just fetch "current"
      
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

      // Generate Home
      // Ideally backend handles generating both or we request specific type
      _homeWorkout = await _workoutRepository.generateAndSaveWorkoutPlan(
        userId: userId!,
        userProfile: {...userProfile, 'preference': 'home'},
      );
      
      // Generate Gym
      _gymWorkout = await _workoutRepository.generateAndSaveWorkoutPlan(
         userId: userId!,
         userProfile: {...userProfile, 'preference': 'gym'},
      );
      
      notifyListeners();
    } catch (e) {
       setError('Failed to generate workouts: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Get current workout list based on selected tab
  List<Exercise> get currentWorkoutExercises {
    return currentPlan?.exercises ?? [];
  }

  /// Get total duration of the current workout
  int get durationMinutes {
    return currentPlan?.durationMinutes ?? 0;
  }

  /// Get total calories burned for the current workout
  int get caloriesBurned {
    return currentPlan?.totalCalories ?? 0;
  }

  /// Get total number of exercises
  int get exerciseCount {
    return currentPlan?.exercises.length ?? 0;
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
