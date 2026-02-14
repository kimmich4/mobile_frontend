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
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: (json['name'] as String?) ?? 'Exercise',
    difficulty: (json['difficulty'] as String?) ?? 'Medium',
    equipment: (json['equipment'] as String?) ?? 'None',
    sets: (json['sets'] as String?)?.toString() ?? '3', // API might return int
    reps: (json['reps'] as String?)?.toString() ?? '10', // API might return int
    calories: (json['calories'] as num?)?.toInt() ?? 0,
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
    title: (json['title'] as String?) ?? 'Workout Plan',
    durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
    exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
    exercises: (json['exercises'] as List<dynamic>?)
            ?.map((ex) => Exercise.fromJson(ex as Map<String, dynamic>))
            .toList() ??
        [],
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
