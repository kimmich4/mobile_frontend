import 'package:firebase_auth/firebase_auth.dart';
import 'base_view_model.dart';
import '../data/models/diet_model.dart';
import '../data/repositories/diet_repository.dart';
import '../data/repositories/user_repository.dart';

/// ViewModel for Diet Screen — includes meal completion tracking
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

  // Track completed meals per day: key = dayIndex, value = set of meal indices
  final Map<int, Set<int>> _completedMeals = {};

  /// Initialize and fetch data
  Future<void> init() async {
    // Default to current weekday (Mon=0 .. Sun=6)
    _selectedDayIndex = DateTime.now().weekday - 1; // weekday is 1-7
    await fetchDietPlan();
    await _loadCompletedMeals();
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

  /// Load completed meals from Firestore for today
  Future<void> _loadCompletedMeals() async {
    if (userId == null) return;
    try {
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel != null && userModel.completedMeals.isNotEmpty) {
        // Load all completed meals across all days from the map
        _completedMeals.clear();
        userModel.completedMeals.forEach((dayIndex, mealsList) {
          _completedMeals[dayIndex] = Set<int>.from(mealsList);
        });
        notifyListeners();
      }
    } catch (_) {}
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

      // 3. Sync dailyCalorieGoal to user doc from day 1 of plan
      if (_dietPlan != null && _dietPlan!.days.isNotEmpty) {
        final day1Calories = _dietPlan!.days.first.totalCalories;
        if (day1Calories > 0) {
          await _userRepository.updateFields(userId!, {
            'dailyCalorieGoal': day1Calories,
          });
        }
      }

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
    
    return {
      'calories': plan.totalCalories,
      'protein': plan.protein,
      'carbs': plan.carbs,
      'fats': plan.fats,
      'meals': plan.meals.asMap().entries.map((entry) => {
        'index': entry.key,
        'title': entry.value.title,
        'cal': '${entry.value.totalCalories} cal',
        'items': entry.value.items.map((it) => {
          'name': it.name,
          'cal': '${it.calories} cal'
        }).toList()
      }).toList()
    };
  }

  /// Check if a meal is completed
  bool isMealCompleted(int mealIndex) {
    return _completedMeals[_selectedDayIndex]?.contains(mealIndex) ?? false;
  }

  /// Toggle meal completion — updates calories consumed and progress tracking
  Future<void> toggleMealCompletion(int mealIndex) async {
    // Update local state
    _completedMeals[_selectedDayIndex] ??= {};
    if (_completedMeals[_selectedDayIndex]!.contains(mealIndex)) {
      _completedMeals[_selectedDayIndex]!.remove(mealIndex);
    } else {
      _completedMeals[_selectedDayIndex]!.add(mealIndex);
    }
    notifyListeners();

    // Persist to Firestore
    if (userId == null) return;
    try {
      // Calculate total calories consumed from completed meals
      final plan = currentDayPlan;
      if (plan == null) return;

      int totalConsumed = 0;
      final completedSet = _completedMeals[_selectedDayIndex] ?? {};
      for (int i = 0; i < plan.meals.length; i++) {
        if (completedSet.contains(i)) {
          totalConsumed += plan.meals[i].totalCalories;
        }
      }

      // Update the whole completedMeals map in Firestore
      final updatedMealsMap = _completedMeals.map((key, value) => MapEntry(key.toString(), value.toList()));
      
      // Calculate total calories consumed from completed meals for TODAY
      final todayIndex = DateTime.now().weekday - 1;
      
      final Map<String, dynamic> updates = {
         'completedMeals': updatedMealsMap,
      };
      
      // Only update currentCalories counter if we are modifying today's meals
      if (_selectedDayIndex == todayIndex) {
        updates['currentCalories'] = totalConsumed;
      }
      
      await _userRepository.updateFields(userId!, updates);
    } catch (e) {
      print('Error persisting meal completion: $e');
    }
  }

  /// Get count of completed meals for the selected day
  int get completedMealsCount {
    return _completedMeals[_selectedDayIndex]?.length ?? 0;
  }

  /// Select a specific day
  void selectDay(int dayIndex) {
    if (_selectedDayIndex != dayIndex) {
      _selectedDayIndex = dayIndex;
      notifyListeners();
    }
  }

  /// Get formatted date string
  String getFormattedDate() {
    return "Weekly Plan - Day ${_selectedDayIndex + 1}";
  }
}
