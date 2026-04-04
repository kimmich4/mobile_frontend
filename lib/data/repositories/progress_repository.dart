import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';
import '../models/user_model.dart';
import '../models/diet_model.dart';
import '../models/workout_model.dart';

// ---------------------------------------------------------------------------
// Helper: date range for a given period
// ---------------------------------------------------------------------------
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

  // ─── Firestore collection helpers ───────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _getProgressCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('progress');

  CollectionReference<Map<String, dynamic>> _getDailyLogsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('dailyLogs');

  CollectionReference<Map<String, dynamic>> _getWeightLogsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('weightLogs');

  // ─── Period date-range helper ────────────────────────────────────────────

  /// Returns [start, end] DateTime for the selected period, always in the
  /// current calendar week / month / year.
  _DateRange _getPeriodDateRange(ProgressPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ProgressPeriod.week:
        // Monday 00:00 → Sunday 23:59:59
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return _DateRange(start, end);

      case ProgressPeriod.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        return _DateRange(start, end);

      case ProgressPeriod.year:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1).subtract(const Duration(seconds: 1));
        return _DateRange(start, end);
    }
  }

  // ─── WEIGHT LOGS — real Firebase read ───────────────────────────────────

  /// Fetch actual per-day weight logs for a given period from Firebase.
  ///
  /// Week  → 7 slots (Mon–Sun), only logged days have a point.
  /// Month → one point per logged day (x-label = day-of-month number).
  /// Year  → one point per month that has logs (x-label = 'Jan', 'Feb', …).
  Future<List<WeightDataPoint>> fetchWeightLogsForPeriod(
      String userId, ProgressPeriod period) async {
    try {
      final range = _getPeriodDateRange(period);

      final snapshot = await _getWeightLogsCollection(userId)
          .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
          .orderBy('loggedAt')
          .get();

      if (snapshot.docs.isEmpty) return [];

      // De-duplicate: keep LATEST entry per calendar day
      final Map<String, _RawWeightLog> byDay = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ts = data['loggedAt'];
        if (ts == null) continue;
        final loggedAt = (ts as Timestamp).toDate();
        final dayKey = loggedAt.toIso8601String().split('T').first; // YYYY-MM-DD
        final weight = (data['trackedWeightKg'] as num?)?.toDouble();
        if (weight == null || weight <= 0) continue;
        byDay[dayKey] = _RawWeightLog(date: loggedAt, weight: weight);
      }

      if (byDay.isEmpty) return [];

      switch (period) {
        case ProgressPeriod.week:
          return _buildWeeklyWeightPoints(byDay);
        case ProgressPeriod.month:
          return _buildMonthlyWeightPoints(byDay);
        case ProgressPeriod.year:
          return _buildYearlyWeightPoints(byDay);
      }
    } catch (_) {
      return [];
    }
  }

  /// Week: fills Mon–Sun slots; days without a log are skipped (no data point).
  List<WeightDataPoint> _buildWeeklyWeightPoints(Map<String, _RawWeightLog> byDay) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final List<WeightDataPoint> points = [];

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final key = day.toIso8601String().split('T').first;
      final log = byDay[key];
      if (log != null) {
        points.add(WeightDataPoint(day: labels[i], weight: log.weight, date: log.date, x: i.toDouble()));
      }
    }
    return points;
  }

  /// Month: one point per logged day; x-label = day number as string.
  List<WeightDataPoint> _buildMonthlyWeightPoints(Map<String, _RawWeightLog> byDay) {
    final sortedKeys = byDay.keys.toList()..sort();
    return sortedKeys.map((key) {
      final log = byDay[key]!;
      final dayNum = log.date.day;
      return WeightDataPoint(day: dayNum.toString(), weight: log.weight, date: log.date, x: dayNum.toDouble());
    }).toList();
  }

  /// Year: aggregate logs into 12 monthly averages; skips months with no data.
  List<WeightDataPoint> _buildYearlyWeightPoints(Map<String, _RawWeightLog> byDay) {
    const monthLabels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    // Group by month
    final Map<int, List<double>> byMonth = {};
    for (final log in byDay.values) {
      final m = log.date.month; // 1-12
      byMonth.putIfAbsent(m, () => []).add(log.weight);
    }

    final List<WeightDataPoint> points = [];
    for (int m = 1; m <= 12; m++) {
      final vals = byMonth[m];
      if (vals != null && vals.isNotEmpty) {
        final avg = vals.reduce((a, b) => a + b) / vals.length;
        points.add(WeightDataPoint(
          day: monthLabels[m - 1],
          weight: double.parse(avg.toStringAsFixed(1)),
          date: DateTime(DateTime.now().year, m, 15),
          x: m.toDouble()
        ));
      }
    }
    return points;
  }

  // ─── CALORIE DATA — real Firebase read ──────────────────────────────────

  /// Fetch calorie data for a period from Firebase `dailyLogs`.
  ///
  /// Week  → 7 day bars  (Mon–Sun).
  /// Month → 4-5 weekly  bars  (W1–W4/W5, averaged).
  /// Year  → 12 monthly  bars  (Jan–Dec, averaged per day).
  Future<List<CalorieDataPoint>> fetchCaloriesForPeriod(
      String userId, ProgressPeriod period) async {
    try {
      final range = _getPeriodDateRange(period);

      // dailyLogs docs use YYYY-MM-DD as ID — range query works directly
      final snapshot = await _getDailyLogsCollection(userId)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: range.startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: range.endStr)
          .get();

      // Build map: dateStr → (burned, consumed)
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

  /// Week: 7 daily bars Mon–Sun.
  List<CalorieDataPoint> _buildWeeklyCaloriePoints(
      Map<String, _RawCalorieLog> byDate, DateTime monday) {
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

  /// Month: group days into ISO weeks within the month. Returns W1–W4 (or W5).
  List<CalorieDataPoint> _buildMonthlyCaloriePoints(
      Map<String, _RawCalorieLog> byDate, DateTime monthStart) {
    // Determine how many weeks the month spans
    final Map<int, List<_RawCalorieLog>> byWeek = {};
    for (final entry in byDate.entries) {
      final date = DateTime.parse(entry.key);
      // week index within month (0-based): day 1-7 = W0, 8-14 = W1 ...
      final weekIdx = (date.day - 1) ~/ 7;
      byWeek.putIfAbsent(weekIdx, () => []).add(entry.value);
    }

    if (byWeek.isEmpty) return [];

    final List<CalorieDataPoint> points = [];
    final weekCount = byWeek.keys.reduce((a, b) => a > b ? a : b) + 1;
    for (int w = 0; w < weekCount; w++) {
      final logs = byWeek[w] ?? [];
      final burned = logs.isEmpty ? 0 : (logs.map((l) => l.burned).reduce((a, b) => a + b) / logs.length).round();
      final consumed = logs.isEmpty ? 0 : (logs.map((l) => l.consumed).reduce((a, b) => a + b) / logs.length).round();
      points.add(CalorieDataPoint(day: 'W${w + 1}', burned: burned, consumed: consumed));
    }
    return points;
  }

  /// Year: 12 monthly bars — average burned/consumed per logged day in each month.
  List<CalorieDataPoint> _buildYearlyCaloriePoints(Map<String, _RawCalorieLog> byDate) {
    const monthLabels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final Map<int, List<_RawCalorieLog>> byMonth = {};
    for (final entry in byDate.entries) {
      final date = DateTime.parse(entry.key);
      byMonth.putIfAbsent(date.month, () => []).add(entry.value);
    }

    return List.generate(12, (i) {
      final m = i + 1;
      final logs = byMonth[m] ?? [];
      final burned = logs.isEmpty ? 0 : (logs.map((l) => l.burned).reduce((a, b) => a + b) / logs.length).round();
      final consumed = logs.isEmpty ? 0 : (logs.map((l) => l.consumed).reduce((a, b) => a + b) / logs.length).round();
      return CalorieDataPoint(day: monthLabels[i], burned: burned, consumed: consumed);
    });
  }

  // ─── PROGRESS STATS — period-aware ──────────────────────────────────────

  /// Compute progress stats dynamically.
  /// For weight change and workout counts, reads real Firebase data for the period.
  Future<ProgressStats> computeProgressStats(
    String userId,
    UserModel user,
    ProgressPeriod period, {
    DietPlan? dietPlan,
    WorkoutPlan? homeWorkout,
    WorkoutPlan? gymWorkout,
  }) async {
    final range = _getPeriodDateRange(period);

    // ── 1. Weight calculations from Firebase weightLogs ──
    final initialWeight = user.weightKg ?? 0.0;
    double currentWeight = user.trackedWeightKg ?? user.currentWeightKg ?? initialWeight;
    double periodStartWeight = initialWeight;

    try {
      // Fetch logs sorted ascending for this period
      final weightSnap = await _getWeightLogsCollection(userId)
          .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(range.end))
          .orderBy('loggedAt')
          .get();

      if (weightSnap.docs.isNotEmpty) {
        final firstLog = (weightSnap.docs.first.data()['trackedWeightKg'] as num?)?.toDouble();
        final lastLog = (weightSnap.docs.last.data()['trackedWeightKg'] as num?)?.toDouble();
        
        // Always use first log of the period as baseline
        if (firstLog != null) periodStartWeight = firstLog;
        if (lastLog != null) currentWeight = lastLog;
      }
    } catch (_) {
      // Fallback to user model weights if Firebase query fails
    }

    final weightLost = periodStartWeight - currentWeight; // positive = lost
    final goalWeight = user.goalWeightKg ?? currentWeight;
    final toGoal = (currentWeight - goalWeight).abs();

    // ── 2. Avg calories ──
    int avgCaloriesBurned = 0;
    if (period == ProgressPeriod.week) {
      // Always calculate current week from raw user data (100% accurate)
      avgCaloriesBurned = _computeWeeklyAvgCaloriesFromPlan(user, homeWorkout, gymWorkout);
    } else {
      // Calculate month/year from dailyLogs
      try {
        final calSnap = await _getDailyLogsCollection(userId)
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: range.startStr)
            .where(FieldPath.documentId, isLessThanOrEqualTo: range.endStr)
            .get();

        if (calSnap.docs.isNotEmpty) {
          int totalBurned = 0;
          for (final doc in calSnap.docs) {
            totalBurned += (doc.data()['caloriesBurned'] as num?)?.toInt() ?? 0;
          }
          final daysElapsed = DateTime.now().difference(range.start).inDays + 1;
          avgCaloriesBurned = daysElapsed > 0 ? (totalBurned / daysElapsed).round() : 0;
        }
      } catch (_) {}
    }

    // ── 3. Workout count ──
    int workoutsCompleted = 0;
    if (period == ProgressPeriod.week) {
      // Calculate week workout count cleanly from user struct
      workoutsCompleted = _computeWeeklyWorkoutCount(user, homeWorkout, gymWorkout);
    } else {
      try {
        final workSnap = await _getDailyLogsCollection(userId)
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: range.startStr)
            .where(FieldPath.documentId, isLessThanOrEqualTo: range.endStr)
            .get();

        for (final doc in workSnap.docs) {
          final completed = doc.data()['workoutCompleted'] as bool? ?? false;
          if (completed) workoutsCompleted++;
        }
      } catch (_) {}
    }

    // Workout goal varies by period
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

    // ── 4. Time to goal estimate ──
    final toGoalTime = _estimateTimeToGoal(toGoal, weightLost);

    String toGoalLabel = 'To Goal';
    if (currentWeight > goalWeight + 0.1) {
      toGoalLabel = 'To Lose';
    } else if (currentWeight < goalWeight - 0.1) {
      toGoalLabel = 'To Gain';
    }

    // ── 5. Period label for weight card ──
    final weightLostPeriod = weightLost >= 0 
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

  /// Weekly calorie computation from the exact plan completion state
  int _computeWeeklyAvgCaloriesFromPlan(
      UserModel user, WorkoutPlan? homeWorkout, WorkoutPlan? gymWorkout) {
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

  /// Weekly workout completion count from exact plan completion state
  int _computeWeeklyWorkoutCount(UserModel user, WorkoutPlan? homeWorkout, WorkoutPlan? gymWorkout) {
    int completedDays = 0;
    for (int day = 1; day <= 7; day++) {
      final hasHome = (user.completedHomeExercises[day]?.isNotEmpty ?? false);
      final hasGym = (user.completedGymExercises[day]?.isNotEmpty ?? false);
      if (hasHome || hasGym) completedDays++;
    }
    return completedDays;
  }

  /// Estimate time remaining to reach goal weight.
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

  // ─── LEGACY / PERSISTENCE METHODS (unchanged) ────────────────────────────

  /// Save or update progress stats snapshot to Firebase
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

  /// Fetch user's current progress stats snapshot (legacy — kept for backward compat)
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

  /// Get daily logs consistency (legacy — kept for backward compat)
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
          logsByDay[dayLabels[i]] = doc.data()?['workoutCompleted'] as bool? ?? false;
        }
      }

      final todayWeekday = now.weekday;
      return List.generate(7, (i) {
        final dayNumber = i + 1;
        final isCompleted = dayNumber <= todayWeekday
            ? (logsByDay[dayLabels[i]] ?? false)
            : false;
        return WorkoutDayStatus(dayName: dayLabels[i], isCompleted: isCompleted);
      });
    } catch (_) {
      return dayLabels.map((name) => WorkoutDayStatus(dayName: name, isCompleted: false)).toList();
    }
  }
}

// ─── Internal helpers ───────────────────────────────────────────────────────

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
