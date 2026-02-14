import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// ViewModel for Edit Profile Screen
class EditProfileViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  StreamSubscription<User?>? _authSubscription;
  
  UserModel? _originalUser;

  // Basic Information
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String _selectedGender = 'Male';

  // Body Metrics
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';

  // Health Information
  final List<String> medicalConditionsOptions = ['Diabetes', 'Hypertension', 'Heart Disease', 'Asthma', 'None'];
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
  final ImagePicker _picker = ImagePicker();

  // Profile Picture
  String? _profilePicturePath;
  String? _selectedProfilePicturePath; // Local path before upload

  // Getters
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
  String? get profilePicturePath => _profilePicturePath;
  String? get selectedProfilePicturePath => _selectedProfilePicturePath;
  String get profileInitial => _originalUser?.profileInitial ?? (nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : 'U');

  EditProfileViewModel() {
    _initAuthListener();
  }

  void _initAuthListener() {
    // Listen to auth state changes to reload data when user switches
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadUserData();
      } else {
        _clearFormData();
      }
    });
  }

  void _clearFormData() {
    _originalUser = null;
    nameController.clear();
    ageController.clear();
    weightController.clear();
    heightController.clear();
    otherMedicalConditionController.clear();
    otherAllergyController.clear();
    otherInjuryController.clear();
    _selectedMedicalConditions.clear();
    _selectedAllergies.clear();
    _selectedInjuries.clear();
    _selectedGender = 'Male';
    _selectedActivityLevel = 'Sedentary';
    _medicalConditionOtherSelected = false;
    _allergyOtherSelected = false;
    _injuryOtherSelected = false;
    _medicalReportName = null;
    _inBodyReportName = null;
    _profilePicturePath = null;
    _selectedProfilePicturePath = null;
    notifyListeners();
  }

  /// Load user data from Firestore to pre-fill the form
  Future<void> loadUserData() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    setLoading(true);
    try {
      final userModel = await _userRepository.getUserProfile(user.uid);
      if (userModel != null) {
        _originalUser = userModel;
        nameController.text = userModel.fullName ?? '';
        ageController.text = userModel.age?.toString() ?? '';
        _selectedGender = userModel.gender ?? 'Male';
        weightController.text = userModel.weightKg?.toString() ?? '';
        heightController.text = userModel.heightCm?.toString() ?? '';
        _selectedActivityLevel = userModel.activityLevel ?? 'Sedentary';
        
        _selectedMedicalConditions.clear();
        _selectedMedicalConditions.addAll(userModel.medicalConditions);
        _medicalConditionOtherSelected = userModel.otherMedicalCondition != null && userModel.otherMedicalCondition!.isNotEmpty;
        otherMedicalConditionController.text = userModel.otherMedicalCondition ?? '';

        _selectedAllergies.clear();
        _selectedAllergies.addAll(userModel.allergies);
        _allergyOtherSelected = userModel.otherAllergy != null && userModel.otherAllergy!.isNotEmpty;
        otherAllergyController.text = userModel.otherAllergy ?? '';

        _selectedInjuries.clear();
        _selectedInjuries.addAll(userModel.currentInjuries);
        _injuryOtherSelected = userModel.otherInjury != null && userModel.otherInjury!.isNotEmpty;
        otherInjuryController.text = userModel.otherInjury ?? '';

        _medicalReportName = userModel.medicalReportName;
        _inBodyReportName = userModel.inBodyReportName;
        _profilePicturePath = userModel.profilePicturePath;
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError('Failed to load profile: $e');
    }
  }

  // Setters
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

  /// Pick file for medical or inbody report
  Future<void> pickFile(bool isMedical) async {
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

  /// Pick profile picture from gallery
  Future<void> pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      _selectedProfilePicturePath = image.path;
      notifyListeners();
    }
  }

  /// Save profile changes to Firestore
  Future<void> saveChanges(VoidCallback onSaved) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      setError('No authenticated user found.');
      return;
    }

    setLoading(true);
    clearError();

    try {
      // Upload profile picture if a new one was selected
      String? uploadedPicturePath = _profilePicturePath;
      if (_selectedProfilePicturePath != null) {
        // Read file as bytes (works on both web and mobile)
        final bytes = await XFile(_selectedProfilePicturePath!).readAsBytes();
        uploadedPicturePath = await _userRepository.uploadProfilePicture(
          user.uid,
          bytes,
          _selectedProfilePicturePath!,
        );
      }

      final updatedUser = (_originalUser ?? UserModel(userId: user.uid)).copyWith(
        fullName: nameController.text.trim(),
        age: int.tryParse(ageController.text),
        gender: _selectedGender,
        weightKg: double.tryParse(weightController.text),
        heightCm: double.tryParse(heightController.text),
        activityLevel: _selectedActivityLevel,
        medicalConditions: _selectedMedicalConditions,
        otherMedicalCondition: _medicalConditionOtherSelected ? otherMedicalConditionController.text.trim() : null,
        allergies: _selectedAllergies,
        otherAllergy: _allergyOtherSelected ? otherAllergyController.text.trim() : null,
        currentInjuries: _selectedInjuries,
        otherInjury: _injuryOtherSelected ? otherInjuryController.text.trim() : null,
        medicalReportName: _medicalReportName,
        inBodyReportName: _inBodyReportName,
        profileInitial: nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : 'U',
        profilePicturePath: uploadedPicturePath,
      );

      await _userRepository.saveUserProfile(updatedUser);
      setLoading(false);
      onSaved();
    } catch (e) {
      setLoading(false);
      setError('Failed to update profile: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherMedicalConditionController.dispose();
    otherAllergyController.dispose();
    otherInjuryController.dispose();
    super.dispose();
  }
}
