/// Represents progress statistics
class ProgressStats {
  final double weightLostKg;
  final String weightLostPeriod; // e.g., 'This week'
  final int avgCaloriesBurned;
  final String caloriesPeriod;   // e.g., 'burned/day'
  final double toGoalKg;
  final String toGoalTime;       // e.g., '~8 weeks'
  final int workoutsCompleted;
  final int workoutsGoal;

  ProgressStats({
    required this.weightLostKg,
    required this.weightLostPeriod,
    required this.avgCaloriesBurned,
    required this.caloriesPeriod,
    required this.toGoalKg,
    required this.toGoalTime,
    required this.workoutsCompleted,
    required this.workoutsGoal,
  });

  String get workoutsDisplay => '$workoutsCompleted/$workoutsGoal';
}

/// Represents weight progress data point
class WeightDataPoint {
  final String day; // 'Mon', 'Tue', etc.
  final double weight;

  WeightDataPoint({required this.day, required this.weight});
}

/// Represents calorie data for a single day
class CalorieDataPoint {
  final String day;
  final int burned;
  final int consumed;

  CalorieDataPoint({
    required this.day,
    required this.burned,
    required this.consumed,
  });
}

/// Represents weekly consistency data
class ConsistencyData {
  final List<WorkoutDayStatus> days;

  ConsistencyData({required this.days});

  /// Calculate completion rate percentage
  double get completionRate {
    if (days.isEmpty) return 0;
    final completed = days.where((d) => d.isCompleted).length;
    return completed / days.length;
  }
}

/// Represents a single day's workout completion status
class WorkoutDayStatus {
  final String dayName;
  final bool isCompleted;

  WorkoutDayStatus({required this.dayName, required this.isCompleted});
}

/// Represents period type for progress tracking
enum ProgressPeriod {
  week,
  month,
  year;

  String get displayName {
    switch (this) {
      case ProgressPeriod.week:
        return 'Week';
      case ProgressPeriod.month:
        return 'Month';
      case ProgressPeriod.year:
        return 'Year';
    }
  }
}
