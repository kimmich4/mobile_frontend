import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/diet_model.dart';
import '../models/workout_model.dart';

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
    } catch (e) {}
    return 'http://localhost:3000';
  } 
  
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generate a 7-day diet plan via AI backend
  Future<DietPlan> generateDietPlan({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/ai/generate-diet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fullName': userProfile['fullName'],
          'age': userProfile['age'],
          'gender': userProfile['gender'],
          'height_cm': userProfile['heightCm'],
          'weight_kg': userProfile['weightKg'],
          'activity_level': userProfile['activityLevel'],
          'goal': (userProfile['fitnessGoals'] as List?)?.join(', ') ?? '',
          'health_conditions': (userProfile['medicalConditions'] as List?)?.join(', ') ?? '',
          'allergies': (userProfile['allergies'] as List?)?.join(', ') ?? '',
          'injuries': (userProfile['currentInjuries'] as List?)?.join(', ') ?? '',
          'experience_level': userProfile['experienceLevel'] ?? '',
          'other_medical': userProfile['otherMedicalCondition'] ?? '',
          'other_allergy': userProfile['otherAllergy'] ?? '',
          'other_injury': userProfile['otherInjury'] ?? '',
          'other_fitness_goal': userProfile['otherFitnessGoal'] ?? '',
          'other_experience': userProfile['otherExperience'] ?? '',
          'medical_report_text': userProfile['medicalReportText'] ?? '',
          'inbody_report_text': userProfile['inBodyReportText'] ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DietPlan.fromJson(data);
      } else {
        throw ApiException('Failed to generate diet plan: ${response.body}', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during diet generation: $e');
    }
  }

  /// Generate workout plans (Gym and Home) via AI backend
  Future<Map<String, WorkoutPlan>> generateWorkoutPlans({
    required String userId,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/ai/generate-workout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fullName': userProfile['fullName'],
          'age': userProfile['age'],
          'gender': userProfile['gender'],
          'height_cm': userProfile['heightCm'],
          'weight_kg': userProfile['weightKg'],
          'activity_level': userProfile['activityLevel'],
          'goal': (userProfile['fitnessGoals'] as List?)?.join(', ') ?? '',
          'health_conditions': (userProfile['medicalConditions'] as List?)?.join(', ') ?? '',
          'allergies': (userProfile['allergies'] as List?)?.join(', ') ?? '',
          'injuries': (userProfile['currentInjuries'] as List?)?.join(', ') ?? '',
          'experience_level': userProfile['experienceLevel'] ?? '',
          'other_medical': userProfile['otherMedicalCondition'] ?? '',
          'other_allergy': userProfile['otherAllergy'] ?? '',
          'other_injury': userProfile['otherInjury'] ?? '',
          'other_fitness_goal': userProfile['otherFitnessGoal'] ?? '',
          'other_experience': userProfile['otherExperience'] ?? '',
          'medical_report_text': userProfile['medicalReportText'] ?? '',
          'inbody_report_text': userProfile['inBodyReportText'] ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'gym': WorkoutPlan.fromJson(data['gym']),
          'home': WorkoutPlan.fromJson(data['home']),
        };
      } else {
        throw ApiException('Failed to generate workout plans: ${response.body}', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during workout generation: $e');
    }
  }

  /// Analyze a report image using OCR on the backend
  Future<String> analyzeReport({
    required XFile image,
    required String type,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _client.post(
        Uri.parse('$_baseUrl/ai/analyze-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Image': base64Image,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['extractedText'] as String;
      } else {
        throw ApiException('Failed to analyze report: ${response.body}', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during report analysis: $e');
    }
  }
}
