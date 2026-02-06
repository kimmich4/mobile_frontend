import 'base_view_model.dart';
import '../data/models/workout_model.dart';

/// ViewModel for Workout Plan Screen
class WorkoutViewModel extends BaseViewModel {
  int _selectedTab = 0; // 0: Home Workout, 1: Gym Workout
  final Set<int> _completedExercises = {};

  int get selectedTab => _selectedTab;
  Set<int> get completedExercises => _completedExercises;

  // Workout summary
  final String workoutTitle = 'Upper Body Strength';
  final int durationMinutes = 45;
  final int totalCalories = 380;
  final int exerciseCount = 6;

  // Home workout exercises
  final List<Exercise> homeWorkoutExercises = [
    Exercise(
      id: 1,
      name: 'Push-ups',
      difficulty: 'Medium',
      equipment: 'Bodyweight',
      sets: '3',
      reps: '15',
      calories: 60,
    ),
    Exercise(
      id: 2,
      name: 'Plank',
      difficulty: 'Easy',
      equipment: 'None',
      sets: '3',
      reps: '60s',
      calories: 40,
    ),
  ];

  // Gym workout exercises
  final List<Exercise> gymWorkoutExercises = [
    Exercise(
      id: 101,
      name: 'Bench Press',
      difficulty: 'Hard',
      equipment: 'Barbell',
      sets: '4',
      reps: '8',
      calories: 120,
    ),
    Exercise(
      id: 102,
      name: 'Deadlift',
      difficulty: 'Hard',
      equipment: 'Barbell',
      sets: '3',
      reps: '5',
      calories: 150,
    ),
  ];

  // Calendar days
  final List<WorkoutCalendarDay> calendarDays = [
    WorkoutCalendarDay(dayName: 'Mon', isCompleted: true),
    WorkoutCalendarDay(dayName: 'Tue', isCompleted: true),
    WorkoutCalendarDay(dayName: 'Wed', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Thu', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Fri', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Sat', isCompleted: false),
    WorkoutCalendarDay(dayName: 'Sun', isCompleted: false),
  ];

  /// Get current workout list based on selected tab
  List<Exercise> get currentWorkoutExercises {
    return _selectedTab == 0 ? homeWorkoutExercises : gymWorkoutExercises;
  }

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
