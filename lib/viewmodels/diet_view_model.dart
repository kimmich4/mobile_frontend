import 'package:firebase_auth/firebase_auth.dart';
import 'base_view_model.dart';
import '../data/models/diet_model.dart';
import '../data/repositories/diet_repository.dart';

import '../data/repositories/user_repository.dart';

/// ViewModel for Diet Screen
class DietViewModel extends BaseViewModel {
  final DietRepository _dietRepository;
  final UserRepository _userRepository;
  
  DietViewModel({DietRepository? dietRepository, UserRepository? userRepository}) 
      : _dietRepository = dietRepository ?? DietRepository(),
        _userRepository = userRepository ?? UserRepository();

  int _selectedDayIndex = 0; // 0-6 (Mon-Sun)

  DietPlan? _dietPlan;
  DietPlan? get dietPlan => _dietPlan;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  int get selectedDayIndex => _selectedDayIndex;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Initialize and fetch data
  Future<void> init() async {
    await fetchDietPlan();
  }

  /// Fetch diet plan
  Future<void> fetchDietPlan() async {
    if (userId == null) return;
    
    setLoading(true);
    clearError();
    
    try {
      _dietPlan = await _dietRepository.getDietPlan(userId!);
      notifyListeners();
    } catch (e) {
      setError('Failed to load diet plan: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Generate a new diet plan using user profile from Firestore
  Future<void> generateDietPlan() async {
    if (userId == null) {
      setError('User not logged in');
      return;
    }

    setLoading(true);
    clearError();

    try {
      // 1. Fetch User Profile
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel == null) {
        throw Exception('User profile not found. Please complete profile setup.');
      }

      // 2. Generate Plan
      _dietPlan = await _dietRepository.generateAndSaveDietPlan(
        userId: userId!,
        userProfile: userModel.toJson(),
      );
      
      notifyListeners();
    } catch (e) {
      setError('Failed to generate diet plan: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get current day's diet plan
  DailyDietPlan? get currentDayPlan {
    if (_dietPlan == null || _dietPlan!.days.isEmpty) return null;
    try {
      return _dietPlan!.days.firstWhere((d) => d.day == (_selectedDayIndex + 1));
    } catch (e) {
      return null;
    }
  }

  /// Get current day's diet data as a Map for UI compatibility
  Map<String, dynamic> get currentDietData {
    final plan = currentDayPlan;
    if (plan == null) return {};
    
    // UI expects specific keys
    return {
      'calories': plan.totalCalories,
      'protein': plan.protein,
      'carbs': plan.carbs,
      'fats': plan.fats,
      'meals': plan.meals.map((m) => {
        'title': m.title,
        'cal': '${m.totalCalories} cal',
        'items': m.items.map((it) => {
          'name': it.name,
          'cal': '${it.calories} cal'
        }).toList()
      }).toList()
    };
  }

  /// Select a specific day
  void selectDay(int dayIndex) {
    if (_selectedDayIndex != dayIndex) {
      _selectedDayIndex = dayIndex;
      notifyListeners();
    }
  }

  /// Get formatted date string (Not used as much with 7-day plan, but kept for UI)
  String getFormattedDate() {
    return "Weekly Plan - Day ${_selectedDayIndex + 1}";
  }
}
