import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/diet_model.dart';
import '../models/workout_model.dart';
// ... previous code continues ...
// remove the wrongly placed imports inside class if any remains from previous diff, 
// but wait, I can just replace the whole top section to be safe.

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  // Determine URL based on platform
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (e) {
      // Platform check can fail on web if not careful, but kIsWeb guards it usually.
      // However, dart:io Platform is not available on web.
      // We should use universal_io or just trust kIsWeb check first.
    }
    return 'http://localhost:3000'; // iOS / Desktop / Web fallback
  } 
  
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generate a diet plan via AI backend
  Future<DailyDietPlan> generateDietPlan({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/ai/generate-diet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'health_conditions': (userProfile['medicalConditions'] as List?)?.join(', ') ?? '',
          'goal': (userProfile['fitnessGoals'] as List?)?.join(', ') ?? '',
          'age': userProfile['age'],
          'height_cm': userProfile['heightCm'],
          'weight_kg': userProfile['weightKg'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DailyDietPlan.fromJson(data);
      } else {
        throw ApiException(
          'Failed to generate diet plan',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Generate a workout plan via AI backend
  Future<WorkoutPlan> generateWorkoutPlan({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/ai/generate-workout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'goal': (userProfile['fitnessGoals'] as List?)?.join(', ') ?? '',
          'age': userProfile['age'],
          'preference': 'gym', // Default or extract from userProfile if available
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WorkoutPlan.fromJson(data);
      } else {
        throw ApiException(
          'Failed to generate workout plan',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
