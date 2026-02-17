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

  factory Exercise.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Exercise(id: 0, name: 'Exercise', difficulty: 'Medium', equipment: 'None', sets: '3', reps: '10', calories: 0);
    return Exercise(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Exercise',
      difficulty: (json['difficulty'] as String?) ?? 'Medium',
      equipment: (json['equipment'] as String?) ?? 'None',
      sets: json['sets']?.toString() ?? '3',
      reps: json['reps']?.toString() ?? '10',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Represents a single day in a workout plan
class WorkoutDay {
  final int day;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.day,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'exercises': exercises.map((ex) => ex.toJson()).toList(),
  };

  factory WorkoutDay.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WorkoutDay(day: 0, exercises: []);
    return WorkoutDay(
      day: (json['day'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((ex) => Exercise.fromJson(ex as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }
}

/// Represents a workout plan (Home or Gym)
class WorkoutPlan {
  final String title; // e.g., 'Upper Body Strength'
  final List<WorkoutDay> days;

  WorkoutPlan({
    required this.title,
    required this.days,
  });

  int get totalCalories {
    int total = 0;
    for (var day in days) {
      for (var ex in day.exercises) {
        total += ex.calories;
      }
    }
    return total;
  }

  int get exerciseCount {
    int total = 0;
    for (var day in days) {
      total += day.exercises.length;
    }
    return total;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'days': days.map((day) => day.toJson()).toList(),
  };

  factory WorkoutPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WorkoutPlan(title: 'Workout Plan', days: []);
    return WorkoutPlan(
      title: (json['title'] as String?) ?? 'Workout Plan',
      days: (json['days'] as List<dynamic>?)
              ?.map((day) => WorkoutDay.fromJson(day as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }
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
