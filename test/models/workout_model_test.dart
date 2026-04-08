import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/data/models/workout_model.dart';

void main() {
  group('WorkoutModel', () {
    test('Exercise toJson and fromJson should be consistent', () {
      final exercise = Exercise(
        id: 1,
        name: 'Push-up',
        difficulty: 'Medium',
        equipment: 'Bodyweight',
        sets: '3',
        reps: '15',
        calories: 50,
      );

      final json = exercise.toJson();
      final fromJson = Exercise.fromJson(json);

      expect(fromJson.id, exercise.id);
      expect(fromJson.name, exercise.name);
      expect(fromJson.calories, exercise.calories);
    });

    test('WorkoutDay toJson and fromJson should be consistent', () {
      final day = WorkoutDay(
        day: 1,
        exercises: [
          Exercise(id: 1, name: 'Ex 1', difficulty: 'M', equipment: 'N', sets: '3', reps: '10', calories: 20),
        ],
      );

      final json = day.toJson();
      final fromJson = WorkoutDay.fromJson(json);

      expect(fromJson.day, day.day);
      expect(fromJson.exercises.length, 1);
      expect(fromJson.exercises[0].name, 'Ex 1');
    });

    test('WorkoutPlan getters should calculate correctly', () {
      final plan = WorkoutPlan(
        title: 'Test Plan',
        days: [
          WorkoutDay(day: 1, exercises: [
            Exercise(id: 1, name: 'Ex 1', difficulty: 'M', equipment: 'N', sets: '3', reps: '10', calories: 20),
            Exercise(id: 2, name: 'Ex 2', difficulty: 'M', equipment: 'N', sets: '3', reps: '10', calories: 30),
          ]),
          WorkoutDay(day: 2, exercises: [
            Exercise(id: 3, name: 'Ex 3', difficulty: 'M', equipment: 'N', sets: '3', reps: '10', calories: 50),
          ]),
        ],
      );

      expect(plan.totalCalories, 100);
      expect(plan.exerciseCount, 3);
    });
  });
}
