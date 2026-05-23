import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';
import '../models/user_model.dart';
import '../models/diet_model.dart';
import '../models/workout_model.dart';

//
// helper: date range for a given period
//
class _DateRange {
  final DateTime start;
  final DateTime end;
  _DateRange(this.start, this.end);

  String get startStr => start.toIso8601String().split('T').first;
  String get endStr => end.toIso8601String().split('T').first;
}

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // firestore collection helpers

  CollectionReference<Map<String, dynamic>> _getProgressCollection(
    String userId,
  ) => _firestore.collection('users').doc(userId).collection('progress');

  CollectionReference<Map<String, dynamic>> _getDailyLogsCollection(
    String userId,
  ) => _firestore.collection('users').doc(userId).collection('dailyLogs');

  CollectionReference<Map<String, dynamic>> _getWeightLogsCollection(
    String userId,
  ) => _firestore.collection('users').doc(userId).collection('weightLogs');

  // period date-range helper

  /// returns [start, end] datetime for the selected period, always in the
  /// current calendar week / month / year.
  _DateRange _getPeriodDateRange(ProgressPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ProgressPeriod.week:
        // monday 00:00 to sunday 23:59:59
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return _DateRange(start, end);

      case ProgressPeriod.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(seconds: 1));
        return _DateRange(start, end);

      case ProgressPeriod.year:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(
          now.year + 1,
          1,
          1,
        ).subtract(const Duration(seconds: 1));
        return _DateRange(start, end);
    }
  }

  // weight logs - real firebase read

  /// fetch actual per-day weight logs for a given period from firebase.
  ///
  /// week to 7 slots (mon-sun), only logged days have a point.
  /// month to one point per logged day (x-label = day-of-month number).
  /// year to one point per month that has logs (x-label = 'jan', 'feb', ...).
  Future<List<WeightDataPoint>> fetchWeightLogsForPeriod(
    String userId,
    ProgressPeriod period,
  ) async {
    try {
      final range = _getPeriodDateRange(period);

      final snapshot =
          await _getWeightLogsCollection(userId)
              .where(
                'loggedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(range.start),
              )
              .where(
                'loggedAt',
                isLessThanOrEqualTo: Timestamp.fromDate(range.end),
              )
              .orderBy('loggedAt')
              .get();

      if (snapshot.docs.isEmpty) return [];

      switch (period) {
        case ProgressPeriod.week:
          return _buildAllWeeklyWeightPoints(snapshot.docs, range.start);
        case ProgressPeriod.month:
          return _buildAllMonthlyWeightPoints(snapshot.docs, range.start);
        case ProgressPeriod.year:
          return _buildAllYearlyWeightPoints(snapshot.docs, range.start);
      }
    } catch (_) {
      return [];
    }
  }

  List<WeightDataPoint> _buildAllWeeklyWeightPoints(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime mondayStart,
  ) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<WeightDataPoint> points = [];

    for (final doc in docs) {
      final data = doc.data();
      final ts = data['loggedAt'];
      if (ts == null) continue;
      final loggedAt = (ts as Timestamp).toDate();
      final weight = (data['trackedWeightKg'] as num?)?.toDouble();
      if (weight == null || weight <= 0) continue;

      final diff = loggedAt.difference(mondayStart);
      final double x = diff.inSeconds / 86400.0;
      int dayIndex = diff.inDays.clamp(0, 6);

      points.add(
        WeightDataPoint(
          day: labels[dayIndex],
          weight: weight,
          date: loggedAt,
          x: x,
        ),
      );
    }
    return points;
  }

  List<WeightDataPoint> _buildAllMonthlyWeightPoints(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime monthStart,
  ) {
    final List<WeightDataPoint> points = [];

    for (final doc in docs) {
      final data = doc.data();
      final ts = data['loggedAt'];
      if (ts == null) continue;
      final loggedAt = (ts as Timestamp).toDate();
      final weight = (data['trackedWeightKg'] as num?)?.toDouble();
      if (weight == null || weight <= 0) continue;

      final int dayNum = loggedAt.day;
      final double timeOffset =
          (loggedAt.hour * 3600 + loggedAt.minute * 60 + loggedAt.second) /
          86400.0;
      final double x = dayNum + timeOffset;

      points.add(
        WeightDataPoint(
          day: dayNum.toString(),
          weight: weight,
          date: loggedAt,
          x: x,
        ),
      );
    }
    return points;
  }

  List<WeightDataPoint> _buildAllYearlyWeightPoints(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime yearStart,
  ) {
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final List<WeightDataPoint> points = [];

    for (final doc in docs) {
      final data = doc.data();
      final ts = data['loggedAt'];
      if (ts == null) continue;
      final loggedAt = (ts as Timestamp).toDate();
      final weight = (data['trackedWeightKg'] as num?)?.toDouble();
      if (weight == null || weight <= 0) continue;

      final int m = loggedAt.month;
      final int d = loggedAt.day;
      final double fraction = (d - 1) / 30.0;
      final double x = m + fraction.clamp(0.0, 0.99);

      points.add(
        WeightDataPoint(
          day: monthLabels[m - 1],
          weight: weight,
          date: loggedAt,
          x: x,
        ),
      );
    }
    return points;
  }

  // calorie data - real firebase read

  /// fetch calorie data for a period from firebase dailylogs.
  ///
  /// week to 7 day bars (mon-sun).
  /// month to 4-5 weekly bars (w1-w4/w5, averaged).
  /// year to 12 monthly bars (jan-dec, averaged per day).
  Future<List<CalorieDataPoint>> fetchCaloriesForPeriod(
    String userId,
    ProgressPeriod period,
  ) async {
    try {
      final range = _getPeriodDateRange(period);

      // dailylogs docs use yyyy-mm-dd as id - range query works directly
      final snapshot =
          await _getDailyLogsCollection(userId)
              .where(
                FieldPath.documentId,
                isGreaterThanOrEqualTo: range.startStr,
              )
              .where(FieldPath.documentId, isLessThanOrEqualTo: range.endStr)
              .get();

      // build map: datestr to (burned, consumed)
      final Map<String, _RawCalorieLog> byDate = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final burned = (data['caloriesBurned'] as num?)?.toInt() ?? 0;
        final consumed = (data['caloriesConsumed'] as num?)?.toInt() ?? 0;
        byDate[doc.id] = _RawCalorieLog(burned: burned, consumed: consumed);
      }

      switch (period) {
        case ProgressPeriod.week:
          return _buildWeeklyCaloriePoints(byDate, range.start);
        case ProgressPeriod.month:
          return _buildMonthlyCaloriePoints(byDate, range.start);
        case ProgressPeriod.year:
          return _buildYearlyCaloriePoints(byDate);
      }
    } catch (_) {
      return [];
    }
  }

  /// week: 7 daily bars mon-sun.
  List<CalorieDataPoint> _buildWeeklyCaloriePoints(
    Map<String, _RawCalorieLog> byDate,
    DateTime monday,
  ) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final key = day.toIso8601String().split('T').first;
      final log = byDate[key];
      return CalorieDataPoint(
        day: labels[i],
        burned: log?.burned ?? 0,
        consumed: log?.consumed ?? 0,
      );
    });
  }

  /// month: group days into iso weeks within the month. returns w1-w4 (or w5).
  List<CalorieDataPoint> _buildMonthlyCaloriePoints(
    Map<String, _RawCalorieLog> byDate,
    DateTime monthStart,
  ) {
    // determine how many weeks the month spans
    final Map<int, List<_RawCalorieLog>> byWeek = {};
    for (final entry in byDate.entries) {
      final date = DateTime.parse(entry.key);
      // week index within month (0-based): day 1-7 = w0, 8-14 = w1 ...
      final weekIdx = (date.day - 1) ~/ 7;
      byWeek.putIfAbsent(weekIdx, () => []).add(entry.value);
    }

    if (byWeek.isEmpty) return [];

    final List<CalorieDataPoint> points = [];
    final weekCount = byWeek.keys.reduce((a, b) => a > b ? a : b) + 1;
    for (int w = 0; w < weekCount; w++) {
      final logs = byWeek[w] ?? [];
      final burned =
          logs.isEmpty
              ? 0
              : (logs.map((l) => l.burned).reduce((a, b) => a + b) /
                      logs.length)
                  .round();
      final consumed =
          logs.isEmpty
              ? 0
              : (logs.map((l) => l.consumed).reduce((a, b) => a + b) /
                      logs.length)
                  .round();
      points.add(
        CalorieDataPoint(day: 'W${w + 1}', burned: burned, consumed: consumed),
      );
    }
    return points;
  }

  /// year: 12 monthly bars - average burned/consumed per logged day in each month.
  List<CalorieDataPoint> _buildYearlyCaloriePoints(
    Map<String, _RawCalorieLog> byDate,
  ) {
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final Map<int, List<_RawCalorieLog>> byMonth = {};
    for (final entry in byDate.entries) {
      final date = DateTime.parse(entry.key);
      byMonth.putIfAbsent(date.month, () => []).add(entry.value);
    }

    return List.generate(12, (i) {
      final m = i + 1;
      final logs = byMonth[m] ?? [];
      final burned =
          logs.isEmpty
              ? 0
              : (logs.map((l) => l.burned).reduce((a, b) => a + b) /
                      logs.length)
                  .round();
      final consumed =
          logs.isEmpty
              ? 0
              : (logs.map((l) => l.consumed).reduce((a, b) => a + b) /
                      logs.length)
                  .round();
      return CalorieDataPoint(
        day: monthLabels[i],
        burned: burned,
        consumed: consumed,
      );
    });
  }

  // progress stats - period-aware

  /// compute progress stats dynamically.
  /// for weight change and workout counts, reads real firebase data for the period.
  Future<ProgressStats> computeProgressStats(
    String userId,
    UserModel user,
    ProgressPeriod period, {
    DietPlan? dietPlan,
    WorkoutPlan? homeWorkout,
    WorkoutPlan? gymWorkout,
  }) async {
    final range = _getPeriodDateRange(period);

    // 1. weight calculations from firebase weightlogs
    final initialWeight = user.weightKg ?? 0.0;
    double currentWeight =
        user.trackedWeightKg ?? user.currentWeightKg ?? initialWeight;
    double periodStartWeight = initialWeight;

    try {
      // fetch logs sorted ascending for this period
      final weightSnap =
          await _getWeightLogsCollection(userId)
              .where(
                'loggedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(range.start),
              )
              .where(
                'loggedAt',
                isLessThanOrEqualTo: Timestamp.fromDate(range.end),
              )
              .orderBy('loggedAt')
              .get();

      if (weightSnap.docs.isNotEmpty) {
        final firstLog =
            (weightSnap.docs.first.data()['trackedWeightKg'] as num?)
                ?.toDouble();
        final lastLog =
            (weightSnap.docs.last.data()['trackedWeightKg'] as num?)
                ?.toDouble();

        // always use first log of the period as baseline
        if (firstLog != null) periodStartWeight = firstLog;
        if (lastLog != null) currentWeight = lastLog;
      }
    } catch (_) {
      // fallback to user model weights if firebase query fails
    }

    final weightLost = periodStartWeight - currentWeight; // positive = lost
    final goalWeight = user.goalWeightKg ?? currentWeight;
    final toGoal = (currentWeight - goalWeight).abs();

    // 2. avg calories
    int avgCaloriesBurned = 0;
    if (period == ProgressPeriod.week) {
      // always calculate current week from raw user data (100% accurate)
      avgCaloriesBurned = _computeWeeklyAvgCaloriesFromPlan(
        user,
        homeWorkout,
        gymWorkout,
      );
    } else {
      // calculate month/year from dailylogs
      try {
        final calSnap =
            await _getDailyLogsCollection(userId)
                .where(
                  FieldPath.documentId,
                  isGreaterThanOrEqualTo: range.startStr,
                )
                .where(FieldPath.documentId, isLessThanOrEqualTo: range.endStr)
                .get();

        if (calSnap.docs.isNotEmpty) {
          int totalBurned = 0;
          for (final doc in calSnap.docs) {
            totalBurned += (doc.data()['caloriesBurned'] as num?)?.toInt() ?? 0;
          }
          final daysElapsed = DateTime.now().difference(range.start).inDays + 1;
          avgCaloriesBurned =
              daysElapsed > 0 ? (totalBurned / daysElapsed).round() : 0;
        }
      } catch (_) {}
    }

    // 3. workout count
    int workoutsCompleted = 0;
    if (period == ProgressPeriod.week) {
      // calculate week workout count cleanly from user struct
      workoutsCompleted = _computeWeeklyWorkoutCount(
        user,
        homeWorkout,
        gymWorkout,
      );
    } else {
      try {
        final workSnap =
            await _getDailyLogsCollection(userId)
                .where(
                  FieldPath.documentId,
                  isGreaterThanOrEqualTo: range.startStr,
                )
                .where(FieldPath.documentId, isLessThanOrEqualTo: range.endStr)
                .get();

        for (final doc in workSnap.docs) {
          final completed = doc.data()['workoutCompleted'] as bool? ?? false;
          if (completed) workoutsCompleted++;
        }
      } catch (_) {}
    }

    // workout goal varies by period
    int workoutsGoal;
    switch (period) {
      case ProgressPeriod.week:
        workoutsGoal = user.workoutsGoalPerWeek ?? 5;
        break;
      case ProgressPeriod.month:
        workoutsGoal = (user.workoutsGoalPerWeek ?? 5) * 4;
        break;
      case ProgressPeriod.year:
        workoutsGoal = (user.workoutsGoalPerWeek ?? 5) * 52;
        break;
    }

    // 4. time to goal estimate
    final toGoalTime = _estimateTimeToGoal(toGoal, weightLost);

    String toGoalLabel = 'To Goal';
    if (currentWeight > goalWeight + 0.1) {
      toGoalLabel = 'To Lose';
    } else if (currentWeight < goalWeight - 0.1) {
      toGoalLabel = 'To Gain';
    }

    // 5. period label for weight card
    final weightLostPeriod =
        weightLost >= 0
            ? 'lost this ${period.displayName.toLowerCase()}'
            : 'gained this ${period.displayName.toLowerCase()}';

    return ProgressStats(
      weightLostKg: double.parse(weightLost.abs().toStringAsFixed(1)),
      weightLostPeriod: weightLostPeriod,
      avgCaloriesBurned: avgCaloriesBurned,
      caloriesPeriod: 'avg/day',
      toGoalKg: double.parse(toGoal.toStringAsFixed(1)),
      toGoalTime: toGoalTime,
      toGoalLabel: toGoalLabel,
      workoutsCompleted: workoutsCompleted,
      workoutsGoal: workoutsGoal,
    );
  }

  /// weekly calorie computation from the exact plan completion state
  int _computeWeeklyAvgCaloriesFromPlan(
    UserModel user,
    WorkoutPlan? homeWorkout,
    WorkoutPlan? gymWorkout,
  ) {
    final todayWeekday = DateTime.now().weekday;
    int totalBurnedCals = 0;

    for (int day = 1; day <= 7; day++) {
      if (homeWorkout != null) {
        final completedHome = user.completedHomeExercises[day] ?? [];
        try {
          final dayPlan = homeWorkout.days.firstWhere((d) => d.day == day);
          for (final ex in dayPlan.exercises) {
            if (completedHome.contains(ex.id)) totalBurnedCals += ex.calories;
          }
        } catch (_) {}
      }
      if (gymWorkout != null) {
        final completedGym = user.completedGymExercises[day] ?? [];
        try {
          final dayPlan = gymWorkout.days.firstWhere((d) => d.day == day);
          for (final ex in dayPlan.exercises) {
            if (completedGym.contains(ex.id)) totalBurnedCals += ex.calories;
          }
        } catch (_) {}
      }
    }

    return todayWeekday > 0 ? (totalBurnedCals / todayWeekday).round() : 0;
  }

  /// weekly workout completion count from exact plan completion state
  int _computeWeeklyWorkoutCount(
    UserModel user,
    WorkoutPlan? homeWorkout,
    WorkoutPlan? gymWorkout,
  ) {
    int completedDays = 0;
    for (int day = 1; day <= 7; day++) {
      bool homeDone = false;
      bool gymDone = false;

      if (homeWorkout != null) {
        try {
          final dayPlan = homeWorkout.days.firstWhere((d) => d.day == day);
          final completedHome = user.completedHomeExercises[day] ?? [];
          homeDone =
              dayPlan.exercises.isNotEmpty &&
              dayPlan.exercises.every((ex) => completedHome.contains(ex.id));
        } catch (_) {}
      }

      if (gymWorkout != null) {
        try {
          final dayPlan = gymWorkout.days.firstWhere((d) => d.day == day);
          final completedGym = user.completedGymExercises[day] ?? [];
          gymDone =
              dayPlan.exercises.isNotEmpty &&
              dayPlan.exercises.every((ex) => completedGym.contains(ex.id));
        } catch (_) {}
      }

      if (homeDone || gymDone) completedDays++;
    }
    return completedDays;
  }

  /// estimate time remaining to reach goal weight.
  String _estimateTimeToGoal(double toGoal, double weightLost) {
    if (toGoal < 0.5) return 'Goal reached! 🎉';
    if (weightLost.abs() > 0.1) {
      final weeklyRate = weightLost.abs().clamp(0.25, 2.0);
      final weeksRemaining = (toGoal / weeklyRate).ceil();
      if (weeksRemaining <= 1) return '~1 week';
      if (weeksRemaining <= 8) return '~$weeksRemaining weeks';
      final months = (weeksRemaining / 4.3).ceil();
      return '~$months months';
    }
    final weeksEstimate = (toGoal / 0.5).ceil();
    if (weeksEstimate <= 8) return '~$weeksEstimate weeks';
    final months = (weeksEstimate / 4.3).ceil();
    return '~$months months';
  }

  // legacy / persistence methods (unchanged)

  /// save or update progress stats snapshot to firebase
  Future<void> updateProgressStats(String userId, ProgressStats stats) async {
    try {
      await _getProgressCollection(userId).doc('currentStats').set({
        'weightLostKg': stats.weightLostKg,
        'weightLostPeriod': stats.weightLostPeriod,
        'avgCaloriesBurned': stats.avgCaloriesBurned,
        'caloriesPeriod': stats.caloriesPeriod,
        'toGoalKg': stats.toGoalKg,
        'toGoalTime': stats.toGoalTime,
        'toGoalLabel': stats.toGoalLabel,
        'workoutsCompleted': stats.workoutsCompleted,
        'workoutsGoal': stats.workoutsGoal,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// log a completed workout for a specific day
  Future<void> logWorkoutCompletion(
    String userId,
    String dayName,
    bool isCompleted, {
    int caloriesBurned = 0,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      await _getDailyLogsCollection(userId).doc(today).set({
        'workoutCompleted': isCompleted,
        'caloriesBurned': caloriesBurned,
        'dayName': dayName,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to log workout completion: $e');
    }
  }

  Future<void> logCalorieConsumption(
    String userId,
    int caloriesConsumed,
  ) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      await _getDailyLogsCollection(userId).doc(today).set({
        'caloriesConsumed': caloriesConsumed,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to log calorie consumption: $e');
    }
  }

  /// fetch user's current progress stats snapshot (legacy - kept for backward compat)
  Future<ProgressStats?> getProgressStats(String userId) async {
    try {
      final doc =
          await _getProgressCollection(userId).doc('currentStats').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return ProgressStats(
          weightLostKg: (data['weightLostKg'] as num?)?.toDouble() ?? 0.0,
          weightLostPeriod: data['weightLostPeriod'] as String? ?? '',
          avgCaloriesBurned: (data['avgCaloriesBurned'] as num?)?.toInt() ?? 0,
          caloriesPeriod: data['caloriesPeriod'] as String? ?? '',
          toGoalKg: (data['toGoalKg'] as num?)?.toDouble() ?? 0.0,
          toGoalTime: data['toGoalTime'] as String? ?? '',
          toGoalLabel: data['toGoalLabel'] as String? ?? 'To Goal',
          workoutsCompleted: (data['workoutsCompleted'] as num?)?.toInt() ?? 0,
          workoutsGoal: (data['workoutsGoal'] as num?)?.toInt() ?? 0,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// get daily logs consistency (legacy - kept for backward compat)
  Future<List<WorkoutDayStatus>> getWeeklyConsistency(String userId) async {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final Map<String, bool> logsByDay = {};

      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        final key = day.toIso8601String().split('T').first;
        final doc = await _getDailyLogsCollection(userId).doc(key).get();
        if (doc.exists) {
          logsByDay[dayLabels[i]] =
              doc.data()?['workoutCompleted'] as bool? ?? false;
        }
      }

      final todayWeekday = now.weekday;
      return List.generate(7, (i) {
        final dayNumber = i + 1;
        final isCompleted =
            dayNumber <= todayWeekday
                ? (logsByDay[dayLabels[i]] ?? false)
                : false;
        return WorkoutDayStatus(
          dayName: dayLabels[i],
          isCompleted: isCompleted,
        );
      });
    } catch (_) {
      return dayLabels
          .map((name) => WorkoutDayStatus(dayName: name, isCompleted: false))
          .toList();
    }
  }
}

// internal helpers

class _RawWeightLog {
  final DateTime date;
  final double weight;
  _RawWeightLog({required this.date, required this.weight});
}

class _RawCalorieLog {
  final int burned;
  final int consumed;
  _RawCalorieLog({required this.burned, required this.consumed});
}
