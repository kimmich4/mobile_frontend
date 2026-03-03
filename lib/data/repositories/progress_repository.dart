import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';
import '../models/user_model.dart';
import '../models/diet_model.dart';
import '../models/workout_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference for a specific user's progress
  /// Structure: users/{userId}/progress/{entryId}
  CollectionReference<Map<String, dynamic>> _getProgressCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('progress');
  }
  
  /// Collection for daily tracking (workouts, calories)
  /// Structure: users/{userId}/dailyLogs/{date}
  CollectionReference<Map<String, dynamic>> _getDailyLogsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('dailyLogs');
  }

  /// Compute progress stats dynamically from real user data
  Future<ProgressStats> computeProgressStats(String userId, UserModel user, {
    DietPlan? dietPlan,
    WorkoutPlan? homeWorkout,
    WorkoutPlan? gymWorkout,
  }) async {
    // --- Weight calculations ---
    final initialWeight = user.weightKg ?? 0.0;
    final currentWeight = user.currentWeightKg ?? initialWeight;
    final goalWeight = user.goalWeightKg ?? currentWeight;

    final weightLost = initialWeight - currentWeight; // positive = lost weight
    final toGoal = (currentWeight - goalWeight).abs();

    // --- Estimate time to goal ---
    String toGoalTime;
    if (toGoal < 0.5) {
      toGoalTime = 'Goal reached! 🎉';
    } else if (weightLost.abs() > 0.1) {
      // Estimate based on average weekly rate
      // Assume user has been tracking for at least 1 week
      final weeklyRate = weightLost.abs().clamp(0.25, 2.0); // reasonable bounds
      final weeksRemaining = (toGoal / weeklyRate).ceil();
      if (weeksRemaining <= 1) {
        toGoalTime = '~1 week';
      } else if (weeksRemaining <= 8) {
        toGoalTime = '~$weeksRemaining weeks';
      } else {
        final months = (weeksRemaining / 4.3).ceil();
        toGoalTime = '~$months months';
      }
    } else {
      // No weight change yet — estimate with safe 0.5 kg/week default
      final weeksEstimate = (toGoal / 0.5).ceil();
      if (weeksEstimate <= 8) {
        toGoalTime = '~$weeksEstimate weeks';
      } else {
        final months = (weeksEstimate / 4.3).ceil();
        toGoalTime = '~$months months';
      }
    }

    // --- Average calories burned from completed workout exercises ---
    int avgCaloriesBurned = 0;
    int totalBurnedDays = 0;
    int totalBurnedCals = 0;

    final todayWeekday = DateTime.now().weekday; // 1=Mon..7=Sun
    for (int day = 1; day <= 7; day++) {
      int dayBurned = 0;
      // Home workout
      if (homeWorkout != null) {
        final completedHome = user.completedHomeExercises[day] ?? [];
        try {
          final dayPlan = homeWorkout.days.firstWhere((d) => d.day == day);
          for (final ex in dayPlan.exercises) {
            if (completedHome.contains(ex.id)) {
              dayBurned += ex.calories;
            }
          }
        } catch (_) {}
      }
      // Gym workout
      if (gymWorkout != null) {
        final completedGym = user.completedGymExercises[day] ?? [];
        try {
          final dayPlan = gymWorkout.days.firstWhere((d) => d.day == day);
          for (final ex in dayPlan.exercises) {
            if (completedGym.contains(ex.id)) {
              dayBurned += ex.calories;
            }
          }
        } catch (_) {}
      }

      if (dayBurned > 0 || day <= todayWeekday) {
        totalBurnedCals += dayBurned;
        totalBurnedDays++;
      }
    }
    avgCaloriesBurned = totalBurnedDays > 0 ? (totalBurnedCals / totalBurnedDays).round() : 0;

    // --- Workouts ---
    final workoutsCompleted = user.workoutsCompletedThisWeek ?? 0;
    final workoutsGoal = user.workoutsGoalPerWeek ?? 5;

    // --- Period labels ---
    final weightLostPeriod = weightLost >= 0 ? 'lost overall' : 'gained overall';
    const caloriesPeriod = 'avg/day';

    return ProgressStats(
      weightLostKg: double.parse(weightLost.abs().toStringAsFixed(1)),
      weightLostPeriod: weightLostPeriod,
      avgCaloriesBurned: avgCaloriesBurned,
      caloriesPeriod: caloriesPeriod,
      toGoalKg: double.parse(toGoal.toStringAsFixed(1)),
      toGoalTime: toGoalTime,
      workoutsCompleted: workoutsCompleted,
      workoutsGoal: workoutsGoal,
    );
  }

  /// Get weight chart data points
  /// Uses initial weight, current weight, and any daily log weight entries
  List<WeightDataPoint> getWeightChartData(UserModel user) {
    final initialWeight = user.weightKg ?? 0.0;
    final currentWeight = user.currentWeightKg ?? initialWeight;
    
    if (initialWeight <= 0) return [];

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1; // 0-based

    final List<WeightDataPoint> points = [];

    // Create a smooth curve from initial to current weight across the full 7-day week
    for (int i = 0; i < 7; i++) {
      // Linear interpolation from initial to current
      final progress = i / 6; // 0 for Mon, 1 for Sun
      final weight = initialWeight + (currentWeight - initialWeight) * progress;
      
      points.add(WeightDataPoint(
        day: dayLabels[i],
        weight: double.parse(weight.toStringAsFixed(1)),
      ));
    }

    return points;
  }

  /// Get calorie data for the current week
  /// Returns burned (from completed exercises) and consumed (from completed meals) per day
  List<CalorieDataPoint> getWeeklyCaloriesData(
    UserModel user, {
    DietPlan? dietPlan,
    WorkoutPlan? homeWorkout,
    WorkoutPlan? gymWorkout,
  }) {
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayWeekday = DateTime.now().weekday; // 1=Mon..7=Sun
    final List<CalorieDataPoint> data = [];

    for (int day = 1; day <= 7; day++) {
      // --- Calories burned from completed exercises ---
      int burned = 0;
      if (homeWorkout != null) {
        final completedHome = user.completedHomeExercises[day] ?? [];
        try {
          final dayPlan = homeWorkout.days.firstWhere((d) => d.day == day);
          for (final ex in dayPlan.exercises) {
            if (completedHome.contains(ex.id)) {
              burned += ex.calories;
            }
          }
        } catch (_) {}
      }
      if (gymWorkout != null) {
        final completedGym = user.completedGymExercises[day] ?? [];
        try {
          final dayPlan = gymWorkout.days.firstWhere((d) => d.day == day);
          for (final ex in dayPlan.exercises) {
            if (completedGym.contains(ex.id)) {
              burned += ex.calories;
            }
          }
        } catch (_) {}
      }

      // --- Calories consumed from completed meals ---
      int consumed = 0;
      if (dietPlan != null) {
        // Diet plan uses 0-based day index (day-1) for completedMeals
        final completedMealIndices = user.completedMeals[day - 1] ?? [];
        try {
          final dayDiet = dietPlan.days.firstWhere((d) => d.day == day);
          for (int i = 0; i < dayDiet.meals.length; i++) {
            if (completedMealIndices.contains(i)) {
              consumed += dayDiet.meals[i].totalCalories;
            }
          }
        } catch (_) {}
      }

      // Always include all 7 days for the chart
      data.add(CalorieDataPoint(
        day: dayLabels[day - 1],
        burned: burned,
        consumed: consumed,
      ));
    }

    return data;
  }

  /// Save or update progress stats (Weight, BMI, etc.)
  Future<void> updateProgressStats(String userId, ProgressStats stats) async {
    try {
      final data = {
        'weightLostKg': stats.weightLostKg,
        'weightLostPeriod': stats.weightLostPeriod,
        'avgCaloriesBurned': stats.avgCaloriesBurned,
        'caloriesPeriod': stats.caloriesPeriod,
        'toGoalKg': stats.toGoalKg,
        'toGoalTime': stats.toGoalTime,
        'workoutsCompleted': stats.workoutsCompleted,
        'workoutsGoal': stats.workoutsGoal,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _getProgressCollection(userId).doc('currentStats').set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update progress stats: $e');
    }
  }

  /// Log a completed workout for a specific day
  Future<void> logWorkoutCompletion(String userId, String dayName, bool isCompleted) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      
      await _getDailyLogsCollection(userId).doc(today).set({
        'workoutCompleted': isCompleted,
        'dayName': dayName,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (isCompleted) {
        await _getProgressCollection(userId).doc('currentStats').set({
           'workoutsCompleted': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to log workout completion: $e');
    }
  }

  /// Fetch user's current progress stats (legacy — kept for backward compat)
  Future<ProgressStats?> getProgressStats(String userId) async {
    try {
      final doc = await _getProgressCollection(userId).doc('currentStats').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return ProgressStats(
          weightLostKg: (data['weightLostKg'] as num?)?.toDouble() ?? 0.0,
          weightLostPeriod: data['weightLostPeriod'] as String? ?? '',
          avgCaloriesBurned: (data['avgCaloriesBurned'] as num?)?.toInt() ?? 0,
          caloriesPeriod: data['caloriesPeriod'] as String? ?? '',
          toGoalKg: (data['toGoalKg'] as num?)?.toDouble() ?? 0.0,
          toGoalTime: data['toGoalTime'] as String? ?? '',
          workoutsCompleted: (data['workoutsCompleted'] as num?)?.toInt() ?? 0,
          workoutsGoal: (data['workoutsGoal'] as num?)?.toInt() ?? 0,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get progress stats: $e');
    }
  }

  /// Get daily logs (consistency data) — always returns 7 days Mon-Sun
  Future<List<WorkoutDayStatus>> getWeeklyConsistency(String userId) async {
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    try {
      // Fetch last 7 days of logs
      final now = DateTime.now();
      final Map<String, bool> logsByDay = {};
      
      final querySnapshot = await _getDailyLogsCollection(userId)
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();
          
      for (final doc in querySnapshot.docs) {
        final dayName = doc.data()['dayName'] as String? ?? '';
        final completed = doc.data()['workoutCompleted'] as bool? ?? false;
        if (dayName.isNotEmpty) {
          logsByDay[dayName] = completed;
        }
      }

      // Build full 7-day list, filling in missing days as not completed
      final todayWeekday = now.weekday; // 1=Mon..7=Sun
      return List.generate(7, (i) {
        final dayName = dayLabels[i];
        final dayNumber = i + 1;
        // Only show past/current days as potentially completed
        final isCompleted = dayNumber <= todayWeekday 
            ? (logsByDay[dayName] ?? false) 
            : false;
        return WorkoutDayStatus(dayName: dayName, isCompleted: isCompleted);
      });
    } catch (e) {
      // Return all 7 days as not completed on error
      return dayLabels.map((name) => WorkoutDayStatus(dayName: name, isCompleted: false)).toList();
    }
  }
}
