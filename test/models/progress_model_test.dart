import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/data/models/progress_model.dart';

void main() {
  group('ProgressModel', () {
    test('ProgressStats workoutsDisplay should format correctly', () {
      final stats = ProgressStats(
        weightLostKg: 2.0,
        weightLostPeriod: 'Week',
        avgCaloriesBurned: 300,
        caloriesPeriod: 'burned/day',
        toGoalKg: 5.0,
        toGoalTime: '8 weeks',
        toGoalLabel: 'To Lose',
        workoutsCompleted: 3,
        workoutsGoal: 5,
      );

      expect(stats.workoutsDisplay, '3/5');
    });

    test('ConsistencyData completionRate should calculate correctly', () {
      final consistency = ConsistencyData(
        days: [
          WorkoutDayStatus(dayName: 'Mon', isCompleted: true),
          WorkoutDayStatus(dayName: 'Tue', isCompleted: false),
          WorkoutDayStatus(dayName: 'Wed', isCompleted: true),
          WorkoutDayStatus(dayName: 'Thu', isCompleted: false),
        ],
      );

      expect(consistency.completionRate, 0.5);
    });

    test('ProgressPeriod displayName returns correct labels', () {
      expect(ProgressPeriod.week.displayName, 'Week');
      expect(ProgressPeriod.month.displayName, 'Month');
      expect(ProgressPeriod.year.displayName, 'Year');
    });
  });
}
