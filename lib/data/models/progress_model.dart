/// represents progress statistics
class ProgressStats {
  final double weightLostKg;
  final String weightLostPeriod; // e.g., 'this week'
  final int avgCaloriesBurned;
  final String caloriesPeriod;   // e.g., 'burned/day'
  final double toGoalKg;
  final String toGoalTime;       // e.g., '~8 weeks'
  final String toGoalLabel;      // e.g., 'to lose' or 'to gain'
  final int workoutsCompleted;
  final int workoutsGoal;

  ProgressStats({
    required this.weightLostKg,
    required this.weightLostPeriod,
    required this.avgCaloriesBurned,
    required this.caloriesPeriod,
    required this.toGoalKg,
    required this.toGoalTime,
    required this.toGoalLabel,
    required this.workoutsCompleted,
    required this.workoutsGoal,
  });

  String get workoutsDisplay => '$workoutsCompleted/$workoutsGoal';
}

/// represents weight progress data point
class WeightDataPoint {
  final String day;    // label: 'mon', '5', 'jan', etc. - varies by period
  final double weight;
  final DateTime? date; // actual date of the log entry (nullable for backward compat)
  final double x;      // new: explicit x position on the graph to maintain gaps

  WeightDataPoint({required this.day, required this.weight, this.date, required this.x});
}

/// represents calorie data for a single day
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

/// represents weekly consistency data
class ConsistencyData {
  final List<WorkoutDayStatus> days;

  ConsistencyData({required this.days});

  /// calculate completion rate percentage
  double get completionRate {
    if (days.isEmpty) return 0;
    final completed = days.where((d) => d.isCompleted).length;
    return completed / days.length;
  }
}

/// represents a single day's workout completion status
class WorkoutDayStatus {
  final String dayName;
  final bool isCompleted;

  WorkoutDayStatus({required this.dayName, required this.isCompleted});
}

/// represents period type for progress tracking
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
