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

  /// Generate and save a new workout plan
  Future<WorkoutPlan> generateAndSaveWorkoutPlan({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      // 1. Fetch from API
      final workoutPlan = await _apiService.generateWorkoutPlan(
        userId: userId,
        userProfile: userProfile,
      );

      // 2. Save to Firestore. 
      // Ensure ID matches what ViewModel expects ('home_workout' or 'gym_workout')
      String planId;
      final lowerTitle = workoutPlan.title.toLowerCase();
      
      // We can also check the 'preference' from userProfile if available, to be sure.
      final preference = userProfile['preference']?.toString().toLowerCase();

      if (preference == 'home' || lowerTitle.contains('home')) {
        planId = 'home_workout';
      } else if (preference == 'gym' || lowerTitle.contains('gym')) {
        planId = 'gym_workout';
      } else {
        // Fallback
        planId = lowerTitle.replaceAll(RegExp(r'\s+'), '_');
      }
      
      print('Saving workout plan to Firestore with ID: $planId');
      await _getWorkoutCollection(userId).doc(planId).set(workoutPlan.toJson());

      return workoutPlan;
    } catch (e) {
      throw Exception('Failed to generate and save workout plan: $e');
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
