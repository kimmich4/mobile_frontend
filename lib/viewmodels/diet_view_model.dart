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

  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;

  DailyDietPlan? _currentDietPlan;
  DailyDietPlan? get currentDietPlan => _currentDietPlan;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  DateTime get selectedDate => _selectedDate;
  int get selectedDayIndex => _selectedDayIndex;
  
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Initialize and fetch data
  Future<void> init() async {
    await fetchDietPlanForDate(_selectedDate);
  }

  /// Fetch diet plan for the selected date
  Future<void> fetchDietPlanForDate(DateTime date) async {
    if (userId == null) return;
    
    setLoading(true);
    clearError();
    
    try {
      _currentDietPlan = await _dietRepository.getDietPlanForDate(userId!, date);
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
      _currentDietPlan = await _dietRepository.generateAndSaveDietPlan(
        userId: userId!,
        userProfile: userModel.toJson(),
      );
      
      notifyListeners();
    } catch (e) {
      setError('Failed to generate diet plan: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Get current day's diet data as a Map for UI compatibility
  Map<String, dynamic> get currentDietData {
    if (_currentDietPlan == null) return {};
    return _currentDietPlan!.toJson();
  }

  /// Select a specific day
  void selectDay(int dayIndex) {
    _selectedDayIndex = dayIndex;
    // Calculate new date based on day index
    final int difference = dayIndex - (_selectedDate.weekday - 1);
    final newDate = _selectedDate.add(Duration(days: difference));
    setDate(newDate);
  }

  /// Set a specific date
  void setDate(DateTime date) {
    if (_selectedDate.day == date.day && 
        _selectedDate.month == date.month && 
        _selectedDate.year == date.year) return;
        
    _selectedDate = date;
    _selectedDayIndex = date.weekday - 1;
    fetchDietPlanForDate(date);
    notifyListeners();
  }

  /// Get formatted date string
  String getFormattedDate() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final day = _selectedDate.day.toString();
    String suffix = 'th';
    if (day.endsWith('1') && day != '11') {
      suffix = 'st';
    } else if (day.endsWith('2') && day != '12') {
      suffix = 'nd';
    } else if (day.endsWith('3') && day != '13') {
      suffix = 'rd';
    }
    return "${dayNames[_selectedDate.weekday - 1]}, ${months[_selectedDate.month - 1]} $day$suffix";
  }
}
