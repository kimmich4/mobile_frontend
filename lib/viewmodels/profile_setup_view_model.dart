import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';
import '../data/models/user_model.dart';

/// ViewModel for Profile Setup Screen (4-step process)
class ProfileSetupViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  
  final PageController pageController = PageController();
  int _currentPage = 0;

  // Step 1: Basic Information
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String _selectedGender = 'Male';

  // Step 2: Body Metrics
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';

  // Step 3: Health Information
  final List<String> medicalConditionsOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'None'
  ];
  final List<String> _selectedMedicalConditions = [];
  final TextEditingController otherMedicalConditionController = TextEditingController();
  bool _medicalConditionOtherSelected = false;

  final List<String> allergiesOptions = ['Peanuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Soy', 'None'];
  final List<String> _selectedAllergies = [];
  final TextEditingController otherAllergyController = TextEditingController();
  bool _allergyOtherSelected = false;

  final List<String> injuriesOptions = ['Back Pain', 'Knee Injury', 'Shoulder Pain', 'Ankle Sprain', 'None'];
  final List<String> _selectedInjuries = [];
  final TextEditingController otherInjuryController = TextEditingController();
  bool _injuryOtherSelected = false;

  String? _medicalReportName;
  String? _inBodyReportName;

  // Step 4: Goals & Experience
  final List<String> fitnessGoalsOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Maintain Weight',
    'Improve Endurance',
    'Flexibility'
  ];
  final List<String> _selectedFitnessGoals = [];
  final TextEditingController otherFitnessGoalController = TextEditingController();
  bool _fitnessGoalOtherSelected = false;

  final List<String> experienceLevelOptions = ['Beginner', 'Intermediate', 'Advanced'];
  String? _selectedExperienceLevel;
  final TextEditingController otherExperienceController = TextEditingController();
  bool _experienceOtherSelected = false;

  final ImagePicker _picker = ImagePicker();

  // Getters
  int get currentPage => _currentPage;
  String get selectedGender => _selectedGender;
  String get selectedActivityLevel => _selectedActivityLevel;
  List<String> get selectedMedicalConditions => _selectedMedicalConditions;
  bool get medicalConditionOtherSelected => _medicalConditionOtherSelected;
  List<String> get selectedAllergies => _selectedAllergies;
  bool get allergyOtherSelected => _allergyOtherSelected;
  List<String> get selectedInjuries => _selectedInjuries;
  bool get injuryOtherSelected => _injuryOtherSelected;
  String? get medicalReportName => _medicalReportName;
  String? get inBodyReportName => _inBodyReportName;
  List<String> get selectedFitnessGoals => _selectedFitnessGoals;
  bool get fitnessGoalOtherSelected => _fitnessGoalOtherSelected;
  String? get selectedExperienceLevel => _selectedExperienceLevel;
  bool get experienceOtherSelected => _experienceOtherSelected;

  /// Calculate progress percentage
  double get progressPercentage => (_currentPage + 1) / 4;

  // Setters
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setSelectedGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setSelectedActivityLevel(String level) {
    _selectedActivityLevel = level;
    notifyListeners();
  }

  void toggleMedicalCondition(String condition) {
    if (_selectedMedicalConditions.contains(condition)) {
      _selectedMedicalConditions.remove(condition);
    } else {
      if (condition == 'None') {
        _selectedMedicalConditions.clear();
      } else {
        _selectedMedicalConditions.remove('None');
      }
      _selectedMedicalConditions.add(condition);
    }
    notifyListeners();
  }

  void setMedicalConditionOtherSelected(bool value) {
    _medicalConditionOtherSelected = value;
    notifyListeners();
  }

  void toggleAllergy(String allergy) {
    if (_selectedAllergies.contains(allergy)) {
      _selectedAllergies.remove(allergy);
    } else {
      if (allergy == 'None') {
        _selectedAllergies.clear();
      } else {
        _selectedAllergies.remove('None');
      }
      _selectedAllergies.add(allergy);
    }
    notifyListeners();
  }

  void setAllergyOtherSelected(bool value) {
    _allergyOtherSelected = value;
    notifyListeners();
  }

  void toggleInjury(String injury) {
    if (_selectedInjuries.contains(injury)) {
      _selectedInjuries.remove(injury);
    } else {
      if (injury == 'None') {
        _selectedInjuries.clear();
      } else {
        _selectedInjuries.remove('None');
      }
      _selectedInjuries.add(injury);
    }
    notifyListeners();
  }

  void setInjuryOtherSelected(bool value) {
    _injuryOtherSelected = value;
    notifyListeners();
  }

  void toggleFitnessGoal(String goal) {
    if (_selectedFitnessGoals.contains(goal)) {
      _selectedFitnessGoals.remove(goal);
    } else {
      _selectedFitnessGoals.add(goal);
    }
    notifyListeners();
  }

  void setFitnessGoalOtherSelected(bool value) {
    _fitnessGoalOtherSelected = value;
    notifyListeners();
  }

  void setSelectedExperienceLevel(String? level) {
    _selectedExperienceLevel = level;
    notifyListeners();
  }

  void setExperienceOtherSelected(bool value) {
    _experienceOtherSelected = value;
    notifyListeners();
  }

  /// Navigate to next page or complete setup
  void nextPage(VoidCallback onComplete) {
    if (_currentPage < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeSetup(onComplete);
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (_currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Pick file for medical or inbody report
  Future<void> pickFile({required bool isMedical}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (isMedical) {
        _medicalReportName = image.name;
      } else {
        _inBodyReportName = image.name;
      }
      notifyListeners();
    }
  }

  /// Complete profile setup and save to Firestore using Repository
  Future<void> completeSetup(VoidCallback onComplete) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      setError('No authenticated user found. Please login again.');
      return;
    }

    setLoading(true);
    clearError();

    try {
      // Create UserModel from collected data
      final userModel = UserModel(
        userId: user.uid,
        email: user.email,
        fullName: nameController.text.isNotEmpty ? nameController.text : null,
        age: int.tryParse(ageController.text),
        gender: _selectedGender,
        weightKg: double.tryParse(weightController.text),
        heightCm: double.tryParse(heightController.text),
        activityLevel: _selectedActivityLevel,
        medicalConditions: _selectedMedicalConditions,
        otherMedicalCondition: _medicalConditionOtherSelected
            ? otherMedicalConditionController.text
            : null,
        medicalReportName: _medicalReportName,
        inBodyReportName: _inBodyReportName,
        allergies: _selectedAllergies,
        otherAllergy: _allergyOtherSelected ? otherAllergyController.text : null,
        currentInjuries: _selectedInjuries,
        otherInjury: _injuryOtherSelected ? otherInjuryController.text : null,
        fitnessGoals: _selectedFitnessGoals,
        otherFitnessGoal: _fitnessGoalOtherSelected
            ? otherFitnessGoalController.text
            : null,
        experienceLevel: _selectedExperienceLevel,
        otherExperience: _experienceOtherSelected
            ? otherExperienceController.text
            : null,
        profileInitial: nameController.text.isNotEmpty
            ? nameController.text[0].toUpperCase()
            : 'U',
        // Default values for other fields
        currentCalories: 1847,
        dailyCalorieGoal: 2200,
        workoutsCompletedThisWeek: 4,
        workoutsGoalPerWeek: 5,
        currentStreak: 12,
        isPremiumMember: false,
      );

      // Save via UserRepository
      await _userRepository.saveUserProfile(userModel);

      setLoading(false);
      debugPrint('User Profile Saved via Repository: ${userModel.toJson()}');
      onComplete();
    } catch (e) {
      setLoading(false);
      setError('Failed to save profile: $e');
      debugPrint('Error saving profile: $e');
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherMedicalConditionController.dispose();
    otherAllergyController.dispose();
    otherInjuryController.dispose();
    otherFitnessGoalController.dispose();
    otherExperienceController.dispose();
    super.dispose();
  }
}
