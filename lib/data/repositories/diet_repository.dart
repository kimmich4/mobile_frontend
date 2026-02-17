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

  /// Generate and save a new 7-day diet plan
  Future<DietPlan> generateAndSaveDietPlan({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      print('Generating 7-day diet plan for user: $userId');
      
      // 1. Fetch from API
      final dietPlan = await _apiService.generateDietPlan(
        userId: userId,
        userProfile: userProfile,
      );

      // 2. Save to Firestore as a single 'weekly_diet' document
      print('Saving weekly diet plan to Firestore');
      await _getDietCollection(userId).doc('weekly_diet').set(dietPlan.toJson());
      
      return dietPlan;
    } catch (e) {
      print('Error in generateAndSaveDietPlan: $e');
      throw Exception('Failed to generate and save diet plan: $e');
    }
  }

  /// Get the current diet plan
  Future<DietPlan?> getDietPlan(String userId) async {
    try {
      final doc = await _getDietCollection(userId).doc('weekly_diet').get();
      if (doc.exists && doc.data() != null) {
        return DietPlan.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch diet plan: $e');
    }
  }

  /// Update the diet plan
  Future<void> updateDietPlan(String userId, DietPlan plan) async {
    try {
      await _getDietCollection(userId).doc('weekly_diet').update(plan.toJson());
    } catch (e) {
      throw Exception('Failed to update diet plan: $e');
    }
  }
}
