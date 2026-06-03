import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/diet_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../data/services/api_service.dart';
import 'base_view_model.dart';
import '../data/models/user_model.dart';

/// viewmodel for profile setup screen (4-step process)
class ProfileSetupViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final DietRepository _dietRepository;
  final WorkoutRepository _workoutRepository;

  ProfileSetupViewModel({
    AuthRepository? authRepository,
    UserRepository? userRepository,
    DietRepository? dietRepository,
    WorkoutRepository? workoutRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _userRepository = userRepository ?? UserRepository(),
       _dietRepository = dietRepository ?? DietRepository(),
       _workoutRepository = workoutRepository ?? WorkoutRepository();

  final PageController pageController = PageController();
  int _currentPage = 0;

  // step 1: basic information
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String _selectedGender = 'Male';

  // step 2: body metrics
  final TextEditingController weightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';

  // step 3: health information
  final List<String> medicalConditionsOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'None',
  ];
  final List<String> _selectedMedicalConditions = [];
  final TextEditingController otherMedicalConditionController =
      TextEditingController();
  bool _medicalConditionOtherSelected = false;

  final List<String> allergiesOptions = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Eggs',
    'Soy',
    'None',
  ];
  final List<String> _selectedAllergies = [];
  final TextEditingController otherAllergyController = TextEditingController();
  final TextEditingController dislikedFoodsController = TextEditingController();
  bool _allergyOtherSelected = false;

  final List<String> injuriesOptions = [
    'Back Pain',
    'Knee Injury',
    'Shoulder Pain',
    'Ankle Sprain',
    'None',
  ];
  final List<String> _selectedInjuries = [];
  final TextEditingController otherInjuryController = TextEditingController();
  bool _injuryOtherSelected = false;

  String? _medicalReportName;
  String? _inBodyReportName;
  String? _medicalReportText;
  String? _inBodyReportText;
  bool _isAnalyzingReport = false;

  // step 4: goals & experience
  final List<String> fitnessGoalsOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Maintain Weight',
    'Improve Endurance',
    'Flexibility',
  ];
  final List<String> _selectedFitnessGoals = [];
  final TextEditingController otherFitnessGoalController =
      TextEditingController();
  bool _fitnessGoalOtherSelected = false;

  final List<String> experienceLevelOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  String? _selectedExperienceLevel;
  final TextEditingController otherExperienceController =
      TextEditingController();
  bool _experienceOtherSelected = false;

  int _selectedTrainingDaysPerWeek = 3;
  final List<String> workoutSplitOptions = [
    'Full Body',
    'Upper Lower',
    'Push Pull Legs',
    'Arnold Split',
    'Pro Split',
  ];
  String? _selectedWorkoutSplit;

  final ImagePicker _picker = ImagePicker();

  // getters
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
  String? get medicalReportText => _medicalReportText;
  String? get inBodyReportText => _inBodyReportText;
  bool get isAnalyzingReport => _isAnalyzingReport;
  List<String> get selectedFitnessGoals => _selectedFitnessGoals;
  bool get fitnessGoalOtherSelected => _fitnessGoalOtherSelected;
  String? get selectedExperienceLevel => _selectedExperienceLevel;
  bool get experienceOtherSelected => _experienceOtherSelected;
  int get selectedTrainingDaysPerWeek => _selectedTrainingDaysPerWeek;
  String? get selectedWorkoutSplit => _selectedWorkoutSplit;

  /// calculate progress percentage
  double get progressPercentage => (_currentPage + 1) / 4;

  // setters
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

  void setSelectedTrainingDaysPerWeek(int days) {
    _selectedTrainingDaysPerWeek = days.clamp(1, 7);
    notifyListeners();
  }

  void setSelectedWorkoutSplit(String? split) {
    _selectedWorkoutSplit = split;
    notifyListeners();
  }

  /// navigate to next page or complete setup
  Future<void> nextPage(VoidCallback onComplete) async {
    clearError();
    if (!_validateCurrentPage()) {
      return;
    }

    if (_currentPage < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await completeSetup(onComplete);
    }
  }

  /// navigate to previous page
  void previousPage() {
    if (_currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// pick file for medical or inbody report and analyze it
  Future<void> pickFile({required bool isMedical}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (isMedical) {
        _medicalReportName = image.name;
      } else {
        _inBodyReportName = image.name;
      }
      notifyListeners();

      // trigger ocr analysis
      _isAnalyzingReport = true;
      notifyListeners();

      try {
        final apiService = ApiService();
        final extractedText = await apiService.analyzeReport(
          image: image,
          type: isMedical ? 'medical' : 'inbody',
        );

        if (isMedical) {
          _medicalReportText = extractedText;
        } else {
          _inBodyReportText = extractedText;
        }
        debugPrint(
          'OCR extraction successful: ${extractedText.substring(0, 50)}...',
        );
      } catch (e) {
        debugPrint('OCR extraction failed: $e');
        setError('Failed to extract data from report: $e');
      } finally {
        _isAnalyzingReport = false;
        notifyListeners();
      }
    }
  }

  /// complete profile setup and save to firestore using repository
  Future<void> completeSetup(VoidCallback onComplete) async {
    clearError();
    final validationError = _validateAllPages();
    if (validationError != null) {
      setError(validationError);
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      setError('No authenticated user found. Please login again.');
      return;
    }

    setLoading(true);

    try {
      final fullName = nameController.text.trim();
      final age = int.parse(ageController.text.trim());
      final weight = double.parse(weightController.text.trim());
      final targetWeight = double.parse(targetWeightController.text.trim());
      final height = double.parse(heightController.text.trim());

      // create usermodel from collected data
      final userModel = UserModel(
        userId: user.uid,
        email: user.email,
        fullName: fullName,
        age: age,
        gender: _selectedGender,
        weightKg: weight,
        currentWeightKg: weight,
        goalWeightKg: targetWeight,
        heightCm: height,
        activityLevel: _selectedActivityLevel,
        medicalConditions: _selectedMedicalConditions,
        otherMedicalCondition:
            _medicalConditionOtherSelected
                ? otherMedicalConditionController.text
                : null,
        medicalReportName: _medicalReportName,
        inBodyReportName: _inBodyReportName,
        allergies: _selectedAllergies,
        otherAllergy:
            _allergyOtherSelected ? otherAllergyController.text : null,
        dislikedFoods:
            dislikedFoodsController.text.trim().isNotEmpty
                ? dislikedFoodsController.text.trim()
                : null,
        currentInjuries: _selectedInjuries,
        otherInjury: _injuryOtherSelected ? otherInjuryController.text : null,
        fitnessGoals: _selectedFitnessGoals,
        otherFitnessGoal:
            _fitnessGoalOtherSelected ? otherFitnessGoalController.text : null,
        experienceLevel: _selectedExperienceLevel,
        otherExperience:
            _experienceOtherSelected ? otherExperienceController.text : null,
        trainingDaysPerWeek: _selectedTrainingDaysPerWeek,
        preferredWorkoutSplit: _selectedWorkoutSplit,
        medicalReportText: _medicalReportText,
        inBodyReportText: _inBodyReportText,
        profileInitial: fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
        // generated plan values are written after ai diet generation.
        currentCalories: 0,
        dailyCalorieGoal: 0,
        workoutsCompletedThisWeek: 4,
        workoutsGoalPerWeek: _selectedTrainingDaysPerWeek,
        currentStreak: 12,
        isPremiumMember: false,
      );

      // save via userrepository
      await _userRepository.saveUserProfile(userModel);
      debugPrint('User Profile Saved via Repository');

      // 3. navigation to loading screen (handled by ui)
      setLoading(false);
      onComplete();
    } catch (e) {
      setLoading(false);
      setError('Failed to save profile: $e');
      debugPrint('Error saving profile: $e');
    }
  }

  bool _validateCurrentPage() {
    final error = switch (_currentPage) {
      0 => _validateStep1(),
      1 => _validateStep2(),
      2 => _validateStep3(),
      3 => _validateStep4(),
      _ => null,
    };
    if (error != null) {
      setError(error);
      return false;
    }
    return true;
  }

  String? _validateAllPages() {
    return _validateStep1() ??
        _validateStep2() ??
        _validateStep3() ??
        _validateStep4();
  }

  String? _validateStep1() {
    final fullName = nameController.text.trim();
    if (fullName.isEmpty) return 'Please enter your full name';
    if (fullName.length < 2) return 'Full name must be at least 2 characters';

    final age = int.tryParse(ageController.text.trim());
    if (age == null) return 'Please enter a valid age';
    if (age < 13 || age > 100) return 'Age must be between 13 and 100';

    if (_selectedGender.trim().isEmpty) return 'Please select your gender';
    return null;
  }

  String? _validateStep2() {
    final weight = double.tryParse(weightController.text.trim());
    if (weight == null) return 'Please enter a valid current weight';
    if (weight < 30 || weight > 300) {
      return 'Current weight must be between 30 and 300 kg';
    }

    final targetWeight = double.tryParse(targetWeightController.text.trim());
    if (targetWeight == null) return 'Please enter a valid target weight';
    if (targetWeight < 30 || targetWeight > 300) {
      return 'Target weight must be between 30 and 300 kg';
    }

    final height = double.tryParse(heightController.text.trim());
    if (height == null) return 'Please enter a valid height';
    if (height < 100 || height > 250) {
      return 'Height must be between 100 and 250 cm';
    }

    if (_selectedActivityLevel.trim().isEmpty) {
      return 'Please select your activity level';
    }
    return null;
  }

  String? _validateStep3() {
    if (_selectedMedicalConditions.isEmpty && !_medicalConditionOtherSelected) {
      return 'Please select your medical conditions, or choose None';
    }
    if (_medicalConditionOtherSelected &&
        otherMedicalConditionController.text.trim().isEmpty) {
      return 'Please specify your medical condition';
    }

    if (_selectedAllergies.isEmpty && !_allergyOtherSelected) {
      return 'Please select your allergies, or choose None';
    }
    if (_allergyOtherSelected && otherAllergyController.text.trim().isEmpty) {
      return 'Please specify your allergy';
    }

    if (_selectedInjuries.isEmpty && !_injuryOtherSelected) {
      return 'Please select your current injuries, or choose None';
    }
    if (_injuryOtherSelected && otherInjuryController.text.trim().isEmpty) {
      return 'Please specify your injury';
    }

    return null;
  }

  String? _validateStep4() {
    if (_selectedFitnessGoals.isEmpty && !_fitnessGoalOtherSelected) {
      return 'Please select at least one fitness goal';
    }
    if (_fitnessGoalOtherSelected &&
        otherFitnessGoalController.text.trim().isEmpty) {
      return 'Please specify your fitness goal';
    }

    if ((_selectedExperienceLevel == null ||
            _selectedExperienceLevel!.isEmpty) &&
        !_experienceOtherSelected) {
      return 'Please select your experience level';
    }
    if (_experienceOtherSelected &&
        otherExperienceController.text.trim().isEmpty) {
      return 'Please specify your experience level';
    }

    if (_selectedTrainingDaysPerWeek < 1 || _selectedTrainingDaysPerWeek > 7) {
      return 'Please select training days per week';
    }
    if (_selectedWorkoutSplit == null || _selectedWorkoutSplit!.isEmpty) {
      return 'Please select a workout split';
    }

    return null;
  }

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    heightController.dispose();
    otherMedicalConditionController.dispose();
    otherAllergyController.dispose();
    dislikedFoodsController.dispose();
    otherInjuryController.dispose();
    otherFitnessGoalController.dispose();
    otherExperienceController.dispose();
    super.dispose();
  }
}
