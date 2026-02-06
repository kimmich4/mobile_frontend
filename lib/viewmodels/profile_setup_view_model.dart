import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'base_view_model.dart';
import '../data/models/user_model.dart';

/// ViewModel for Profile Setup Screen (4-step process)
class ProfileSetupViewModel extends BaseViewModel {
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
  String? _medicalReportName;
  String? _inBodyReportName;

  // Step 4: Goals & Experience
  final List<String> fitnessGoalsOptions = [
    'Lose weight',
    'Build muscle',
    'Improve endurance',
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
      _selectedMedicalConditions.add(condition);
    }
    notifyListeners();
  }

  void setMedicalConditionOtherSelected(bool value) {
    _medicalConditionOtherSelected = value;
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

  /// Complete profile setup and create UserModel
  void completeSetup(VoidCallback onComplete) {
    // Create UserModel from collected data
    final user = UserModel(
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
    );

    // In a real app, this would save to a database or service
    // For now, just navigate to main screen
    onComplete();
  }

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherMedicalConditionController.dispose();
    otherFitnessGoalController.dispose();
    otherExperienceController.dispose();
    super.dispose();
  }
}
