/// Represents a single meal item
class MealItem {
  final String name;
  final int calories;

  MealItem({
    required this.name,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {'name': name, 'calories': calories};
  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    name: json['name'] as String,
    calories: json['calories'] as int,
  );
}

/// Represents a meal (breakfast, lunch, dinner, snacks)
class Meal {
  final String title;
  final List<MealItem> items;

  Meal({
    required this.title,
    required this.items,
  });

  /// Calculate total calories for this meal
  int get totalCalories => items.fold(0, (sum, item) => sum + item.calories);

  Map<String, dynamic> toJson() => {
    'title': title,
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    title: json['title'] as String,
    items: (json['items'] as List<dynamic>)
        .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

/// Represents a daily diet plan
class DailyDietPlan {
  final DateTime date;
  final int totalCalories;
  final String protein; // e.g., "105g"
  final String carbs;   // e.g., "170g"
  final String fats;    // e.g., "55g"
  final List<Meal> meals;

  DailyDietPlan({
    required this.date,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.meals,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalCalories': totalCalories,
    'protein': protein,
    'carbs': carbs,
    'fats': fats,
    'meals': meals.map((meal) => meal.toJson()).toList(),
  };

  factory DailyDietPlan.fromJson(Map<String, dynamic> json) => DailyDietPlan(
    date: DateTime.parse(json['date'] as String),
    totalCalories: json['totalCalories'] as int,
    protein: json['protein'] as String,
    carbs: json['carbs'] as String,
    fats: json['fats'] as String,
    meals: (json['meals'] as List<dynamic>)
        .map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
        .toList(),
  );
}

/// Represents weekly diet plan
class WeeklyDietPlan {
  final Map<int, DailyDietPlan> dailyPlans; // key: weekday (0-6)

  WeeklyDietPlan({required this.dailyPlans});

  DailyDietPlan? getPlanForDay(int weekday) => dailyPlans[weekday];
}
