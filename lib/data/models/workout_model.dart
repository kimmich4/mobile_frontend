/// Represents a single exercise
class Exercise {
  final int id;
  final String name;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final String equipment;  // 'Bodyweight', 'Barbell', etc.
  final String sets;       // e.g., "3"
  final String reps;       // e.g., "15" or "60s"
  final int calories;

  Exercise({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'difficulty': difficulty,
    'equipment': equipment,
    'sets': sets,
    'reps': reps,
    'calories': calories,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as int,
    name: json['name'] as String,
    difficulty: json['difficulty'] as String,
    equipment: json['equipment'] as String,
    sets: json['sets'] as String,
    reps: json['reps'] as String,
    calories: json['calories'] as int,
  );
}

/// Represents a workout plan (Home or Gym)
class WorkoutPlan {
  final String title; // e.g., 'Upper Body Strength'
  final int durationMinutes;
  final int totalCalories;
  final int exerciseCount;
  final List<Exercise> exercises;

  WorkoutPlan({
    required this.title,
    required this.durationMinutes,
    required this.totalCalories,
    required this.exerciseCount,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'durationMinutes': durationMinutes,
    'totalCalories': totalCalories,
    'exerciseCount': exerciseCount,
    'exercises': exercises.map((ex) => ex.toJson()).toList(),
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    title: json['title'] as String,
    durationMinutes: json['durationMinutes'] as int,
    totalCalories: json['totalCalories'] as int,
    exerciseCount: json['exerciseCount'] as int,
    exercises: (json['exercises'] as List<dynamic>)
        .map((ex) => Exercise.fromJson(ex as Map<String, dynamic>))
        .toList(),
  );
}

/// Represents workout calendar day status
class WorkoutCalendarDay {
  final String dayName; // 'Mon', 'Tue', etc.
  final bool isCompleted;

  WorkoutCalendarDay({
    required this.dayName,
    required this.isCompleted,
  });
}
