import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('toJson and fromJson should be consistent', () {
      final user = UserModel(
        userId: '123',
        fullName: 'John Doe',
        email: 'john@example.com',
        weightKg: 80.0,
        heightCm: 180.0,
        completedMeals: {0: [1, 2]},
      );

      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);

      expect(fromJson.userId, user.userId);
      expect(fromJson.fullName, user.fullName);
      expect(fromJson.email, user.email);
      expect(fromJson.weightKg, user.weightKg);
      expect(fromJson.heightCm, user.heightCm);
      expect(fromJson.completedMeals[0], [1, 2]);
    });

    test('bmi getter should calculate correctly', () {
      final user = UserModel(weightKg: 70.0, heightCm: 175.0);
      // BMI = 70 / (1.75 * 1.75) = 22.857...
      expect(user.bmi, closeTo(22.857, 0.001));
    });

    test('weightRemainingToGoal should calculate correctly', () {
      final user = UserModel(currentWeightKg: 80.0, goalWeightKg: 75.0);
      expect(user.weightRemainingToGoal, 5.0);
    });

    test('copyWith should work as expected', () {
      final user = UserModel(fullName: 'Original');
      final updatedUser = user.copyWith(fullName: 'Updated');
      expect(updatedUser.fullName, 'Updated');
    });
  });
}
