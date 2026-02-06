import 'base_view_model.dart';
import '../data/models/progress_model.dart';

/// ViewModel for Progress Tracking Screen
class ProgressTrackingViewModel extends BaseViewModel {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  int get selectedPeriod => _selectedPeriod;

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
  final ProgressStats stats = ProgressStats(
    weightLostKg: 1.3,
    weightLostPeriod: 'This week',
    avgCaloriesBurned: 2260,
    caloriesPeriod: 'burned/day',
    toGoalKg: 8.7,
    toGoalTime: '~8 weeks',
    workoutsCompleted: 4,
    workoutsGoal: 5,
  );

  // Weight progress data (example for week view)
  final List<WeightDataPoint> weightData = [
    WeightDataPoint(day: 'Mon', weight: 79.0),
    WeightDataPoint(day: 'Tue', weight: 78.5),
    WeightDataPoint(day: 'Wed', weight: 78.2),
    WeightDataPoint(day: 'Thu', weight: 77.9),
    WeightDataPoint(day: 'Fri', weight: 77.7),
    WeightDataPoint(day: 'Sat', weight: 77.5),
    WeightDataPoint(day: 'Sun', weight: 77.7),
  ];

  // Calories data (burned vs consumed per day)
  final List<CalorieDataPoint> caloriesData = [
    CalorieDataPoint(day: 'Mon', burned: 2400, consumed: 1800),
    CalorieDataPoint(day: 'Tue', burned: 2600, consumed: 2100),
    CalorieDataPoint(day: 'Wed', burned: 2100, consumed: 1600),
    CalorieDataPoint(day: 'Thu', burned: 2800, consumed: 2000),
    CalorieDataPoint(day: 'Fri', burned: 2300, consumed: 1900),
    CalorieDataPoint(day: 'Sat', burned: 1800, consumed: 2200),
    CalorieDataPoint(day: 'Sun', burned: 2200, consumed: 1700),
  ];

  // Consistency data
  final ConsistencyData consistencyData = ConsistencyData(
    days: [
      WorkoutDayStatus(dayName: 'Mon', isCompleted: true),
      WorkoutDayStatus(dayName: 'Tue', isCompleted: true),
      WorkoutDayStatus(dayName: 'Wed', isCompleted: true),
      WorkoutDayStatus(dayName: 'Thu', isCompleted: false),
      WorkoutDayStatus(dayName: 'Fri', isCompleted: true),
      WorkoutDayStatus(dayName: 'Sat', isCompleted: false),
      WorkoutDayStatus(dayName: 'Sun', isCompleted: false),
    ],
  );

  /// Set selected period
  void setSelectedPeriod(int period) {
    _selectedPeriod = period;
    // In a real app, this would trigger data loading for the selected period
    notifyListeners();
  }
}
