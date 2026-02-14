import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';

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

  /// Save or update progress stats (Weight, BMI, etc.)
  Future<void> updateProgressStats(String userId, ProgressStats stats) async {
    try {
      // Storing aggregate stats in a single document 'stats' in the progress collection
      // or directly on the user document. The requirement said "progress data scoped by user".
      // Let's store it in `users/{userId}/progress/stats`
      
      // Note: ProgressStats model doesn't have toJson/fromJson in the code viewing earlier,
      // I might need to add it or map it manually here.
      // The viewed file `progress_model.dart` had `ProgressStats` class but no toJson/fromJson.
      // I will assume I need to map it manually or update the model. 
      // For now, I'll map manually to avoid modifying the model file if not strictly requested, 
      // but modifying the model is cleaner. I'll map manually to be safe for now.
      
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
      // Log for the specific date
      final today = DateTime.now().toIso8601String().split('T').first;
      
      await _getDailyLogsCollection(userId).doc(today).set({
        'workoutCompleted': isCompleted,
        'dayName': dayName, // 'Mon', 'Tue' etc.
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Also update aggregate stats if needed (e.g. increment workoutsCompleted)
      if (isCompleted) {
        await _getProgressCollection(userId).doc('currentStats').update({
           'workoutsCompleted': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to log workout completion: $e');
    }
  }

  /// Fetch user's current progress stats
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

  /// Get daily logs (consistency data)
  Future<List<WorkoutDayStatus>> getWeeklyConsistency(String userId) async {
    try {
      // fetch last 7 days logs
       final querySnapshot = await _getDailyLogsCollection(userId)
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();
          
      return querySnapshot.docs.map((doc) {
        return WorkoutDayStatus(
          dayName: doc.data()['dayName'] ?? '',
          isCompleted: doc.data()['workoutCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      return []; 
    }
  }
}
