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
  final int day; // 1-7
  final int totalCalories;
  final String protein; // e.g., "105g"
  final String carbs;   // e.g., "170g"
  final String fats;    // e.g., "55g"
  final List<Meal> meals;

  DailyDietPlan({
    required this.day,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.meals,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'totalCalories': totalCalories,
    'protein': protein,
    'carbs': carbs,
    'fats': fats,
    'meals': meals.map((meal) => meal.toJson()).toList(),
  };

  factory DailyDietPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DailyDietPlan(day: 1, totalCalories: 0, protein: '0g', carbs: '0g', fats: '0g', meals: []);
    return DailyDietPlan(
      day: (json['day'] as num?)?.toInt() ?? 1,
      totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
      protein: json['protein']?.toString() ?? '0g',
      carbs: json['carbs']?.toString() ?? '0g',
      fats: json['fats']?.toString() ?? '0g',
      meals: (json['meals'] as List<dynamic>?)
              ?.map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Represents a multi-day diet plan
class DietPlan {
  final List<DailyDietPlan> days;

  DietPlan({required this.days});

  Map<String, dynamic> toJson() => {
    'days': days.map((day) => day.toJson()).toList(),
  };

  factory DietPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DietPlan(days: []);
    return DietPlan(
      days: (json['days'] as List<dynamic>?)
              ?.map((day) => DailyDietPlan.fromJson(day as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }
}
