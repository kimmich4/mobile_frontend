import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../services/api_service.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore;
  final ApiService _apiService;

  WorkoutRepository({
    FirebaseFirestore? firestore,
    ApiService? apiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _apiService = apiService ?? ApiService();

  /// Collection reference for a specific user's workout plans
  /// Structure: users/{userId}/workoutPlans/{planId}
  CollectionReference<Map<String, dynamic>> _getWorkoutCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('workoutPlans');
  }

  /// Generate and save new workout plans (Gym and Home)
  Future<Map<String, WorkoutPlan>> generateAndSaveWorkoutPlans({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      // 1. Fetch from API (Returns both gym and home)
      final plans = await _apiService.generateWorkoutPlans(
        userId: userId,
        userProfile: userProfile,
      );

      // 2. Save both to Firestore
      print('Saving gym and home workout plans to Firestore');
      await _getWorkoutCollection(userId).doc('gym_workout').set(plans['gym']!.toJson());
      await _getWorkoutCollection(userId).doc('home_workout').set(plans['home']!.toJson());

      return plans;
    } catch (e) {
      throw Exception('Failed to generate and save workout plans: $e');
    }
  }

  /// Get specific workout plan
  Future<WorkoutPlan?> getWorkoutPlan(String userId, String planId) async {
    try {
      final doc = await _getWorkoutCollection(userId).doc(planId).get();
      if (doc.exists && doc.data() != null) {
        return WorkoutPlan.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch workout plan: $e');
    }
  }

  /// Get all workout plans for the user
  Future<List<WorkoutPlan>> getAllWorkoutPlans(String userId) async {
    try {
      final snapshot = await _getWorkoutCollection(userId).get();
      return snapshot.docs
          .map((doc) => WorkoutPlan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch workout plans: $e');
    }
  }

  // Note: Workout completion status is typically tracked in ProgressRepository,
  // but if the plan itself has 'isCompleted' flags, update here.
}
