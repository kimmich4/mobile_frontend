import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diet_model.dart';
import '../services/api_service.dart';

class DietRepository {
  final FirebaseFirestore _firestore;
  final ApiService _apiService;

  DietRepository({
    FirebaseFirestore? firestore,
    ApiService? apiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _apiService = apiService ?? ApiService();

  /// Collection reference for a specific user's diet plans
  /// Structure: users/{userId}/dietPlans/{planId}
  CollectionReference<Map<String, dynamic>> _getDietCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('dietPlans');
  }

  /// Generate and save a new diet plan
  Future<DailyDietPlan> generateAndSaveDietPlan({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      print('Generating diet plan for user: $userId');
      
      // 1. Fetch from API
      final dietPlan = await _apiService.generateDietPlan(
        userId: userId,
        userProfile: userProfile,
      );
      print('Diet plan generated from API. Date: ${dietPlan.date}');

      // 2. Save to Firestore
      // FORCE the date to be the "current selected date" context if possible, but here we assume "today".
      // Issues arise if backend returns UTC "tomorrow" or "yesterday".
      // Let's normalize to the client's current date YYYY-MM-DD to ensure retrieval works for "today".
      final now = DateTime.now();
      final dateId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      // We should also update the plan's date to match this ID to keep data consistent
      final normalizedPlan = DailyDietPlan(
        date: now, 
        totalCalories: dietPlan.totalCalories,
        protein: dietPlan.protein,
        carbs: dietPlan.carbs,
        fats: dietPlan.fats,
        meals: dietPlan.meals
      );

      print('Saving diet plan to Firestore with ID: $dateId');
      await _getDietCollection(userId).doc(dateId).set(normalizedPlan.toJson());
      print('Diet plan saved successfully.');

      return normalizedPlan;
    } catch (e) {
      print('Error in generateAndSaveDietPlan: $e');
      throw Exception('Failed to generate and save diet plan: $e');
    }
  }

  /// Get diet plan for a specific date
  Future<DailyDietPlan?> getDietPlanForDate(String userId, DateTime date) async {
    try {
      // Manual formatting to ensure local date consistency matches the saving logic
      final dateId = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final doc = await _getDietCollection(userId).doc(dateId).get();

      if (doc.exists && doc.data() != null) {
        return DailyDietPlan.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch diet plan: $e');
    }
  }

  /// Stream of diet plan for a specific date (real-time updates)
  Stream<DailyDietPlan?> getDietPlanStream(String userId, DateTime date) {
    final dateId = date.toIso8601String().split('T').first;
    return _getDietCollection(userId).doc(dateId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return DailyDietPlan.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Update a meal status or item in the diet plan
  Future<void> updateDietPlan(String userId, DailyDietPlan plan) async {
    try {
      final dateId = plan.date.toIso8601String().split('T').first;
      await _getDietCollection(userId).doc(dateId).update(plan.toJson());
    } catch (e) {
      throw Exception('Failed to update diet plan: $e');
    }
  }
}
