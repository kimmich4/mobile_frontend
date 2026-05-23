import '../data/repositories/auth_repository.dart';
import 'base_view_model.dart';
import '../data/models/diet_model.dart';
import '../data/repositories/diet_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/user_repository.dart';

/// viewmodel for diet screen - includes meal completion tracking
class DietViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final DietRepository _dietRepository;
  final UserRepository _userRepository;
  final ProgressRepository _progressRepository;

  DietViewModel({
    AuthRepository? authRepository,
    DietRepository? dietRepository,
    UserRepository? userRepository,
    ProgressRepository? progressRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _dietRepository = dietRepository ?? DietRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _progressRepository = progressRepository ?? ProgressRepository();

  int _selectedDayIndex = 0; // 0-6 (mon-sun)

  DietPlan? _dietPlan;
  DietPlan? get dietPlan => _dietPlan;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  int get selectedDayIndex => _selectedDayIndex;
  
  String? get userId => _authRepository.currentUser?.uid;

  // track completed meals per day: key = dayindex, value = set of meal indices
  final Map<int, Set<int>> _completedMeals = {};

  /// initialize and fetch data
  Future<void> init() async {
    // default to current weekday (mon=0 .. sun=6)
    _selectedDayIndex = DateTime.now().weekday - 1; // weekday is 1-7
    await fetchDietPlan();
    await _loadCompletedMeals();
  }

  /// fetch diet plan
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

  /// load completed meals from firestore for today
  Future<void> _loadCompletedMeals() async {
    if (userId == null) return;
    try {
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel != null && userModel.completedMeals.isNotEmpty) {
        // load all completed meals across all days from the map
        _completedMeals.clear();
        userModel.completedMeals.forEach((dayIndex, mealsList) {
          _completedMeals[dayIndex] = Set<int>.from(mealsList);
        });
        notifyListeners();
      }
    } catch (_) {}
  }

  /// generate a new diet plan using user profile from firestore
  Future<void> generateDietPlan() async {
    if (userId == null) {
      setError('User not logged in');
      return;
    }

    setLoading(true);
    clearError();

    try {
      // 1. fetch user profile
      final userModel = await _userRepository.getUserProfile(userId!);
      if (userModel == null) {
        throw Exception('User profile not found. Please complete profile setup.');
      }

      // 2. generate plan
      _dietPlan = await _dietRepository.generateAndSaveDietPlan(
        userId: userId!,
        userProfile: userModel.toJson(),
      );

      // 3. sync dailycaloriegoal to user doc from day 1 of plan
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

  /// get current day's diet plan
  DailyDietPlan? get currentDayPlan {
    if (_dietPlan == null || _dietPlan!.days.isEmpty) return null;
    try {
      return _dietPlan!.days.firstWhere((d) => d.day == (_selectedDayIndex + 1));
    } catch (e) {
      return null;
    }
  }

  /// get current day's diet data as a map for ui compatibility
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

  /// check if a meal is completed
  bool isMealCompleted(int mealIndex) {
    return _completedMeals[_selectedDayIndex]?.contains(mealIndex) ?? false;
  }

  /// toggle meal completion - updates calories consumed and progress tracking
  Future<void> toggleMealCompletion(int mealIndex) async {
    // update local state
    _completedMeals[_selectedDayIndex] ??= {};
    if (_completedMeals[_selectedDayIndex]!.contains(mealIndex)) {
      _completedMeals[_selectedDayIndex]!.remove(mealIndex);
    } else {
      _completedMeals[_selectedDayIndex]!.add(mealIndex);
    }
    notifyListeners();

    // persist to firestore
    if (userId == null) return;
    try {
      // calculate total calories consumed from completed meals
      final plan = currentDayPlan;
      if (plan == null) return;

      int totalConsumed = 0;
      final completedSet = _completedMeals[_selectedDayIndex] ?? {};
      for (int i = 0; i < plan.meals.length; i++) {
        if (completedSet.contains(i)) {
          totalConsumed += plan.meals[i].totalCalories;
        }
      }

      // update the whole completedmeals map in firestore
      final updatedMealsMap = _completedMeals.map((key, value) => MapEntry(key.toString(), value.toList()));
      
      // calculate total calories consumed from completed meals for today
      final todayIndex = DateTime.now().weekday - 1;
      
      final Map<String, dynamic> updates = {
         'completedMeals': updatedMealsMap,
      };
      
      // only update currentcalories counter if we are modifying today's meals
      if (_selectedDayIndex == todayIndex) {
        updates['currentCalories'] = totalConsumed;
      }
      
      await _userRepository.updateFields(userId!, updates);

      if (_selectedDayIndex == todayIndex) {
        await _progressRepository.logCalorieConsumption(userId!, totalConsumed);
      }
    } catch (e) {
      print('Error persisting meal completion: $e');
    }
  }

  /// get count of completed meals for the selected day
  int get completedMealsCount {
    return _completedMeals[_selectedDayIndex]?.length ?? 0;
  }

  /// select a specific day
  void selectDay(int dayIndex) {
    if (_selectedDayIndex != dayIndex) {
      _selectedDayIndex = dayIndex;
      notifyListeners();
    }
  }

  /// get formatted date string
  String getFormattedDate() {
    return "Weekly Plan - Day ${_selectedDayIndex + 1}";
  }
}
