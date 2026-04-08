import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/data/models/diet_model.dart';

void main() {
  group('DietModel', () {
    test('Meal totalCalories should sum item calories', () {
      final meal = Meal(
        title: 'Breakfast',
        items: [
          MealItem(name: 'Eggs', calories: 200),
          MealItem(name: 'Bread', calories: 150),
        ],
      );
      expect(meal.totalCalories, 350);
    });

    test('DietPlan serialization should be consistent', () {
      final plan = DietPlan(
        days: [
          DailyDietPlan(
            day: 1,
            totalCalories: 1500,
            protein: '100g',
            carbs: '150g',
            fats: '50g',
            meals: [
              Meal(
                title: 'Lunch',
                items: [MealItem(name: 'Chicken', calories: 500)],
              ),
            ],
          ),
        ],
      );

      final json = plan.toJson();
      final fromJson = DietPlan.fromJson(json);

      expect(fromJson.days.length, 1);
      expect(fromJson.days[0].totalCalories, 1500);
      expect(fromJson.days[0].meals[0].title, 'Lunch');
    });
  });
}
