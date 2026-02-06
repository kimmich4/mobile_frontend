import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'base_view_model.dart';

/// ViewModel for Edit Profile Screen
class EditProfileViewModel extends BaseViewModel {
  // Basic Information
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String _selectedGender = 'Male';

  // Body Metrics
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';

  // Health Information
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
  final ImagePicker _picker = ImagePicker();

  // Getters
  String get selectedGender => _selectedGender;
  String get selectedActivityLevel => _selectedActivityLevel;
  List<String> get selectedMedicalConditions => _selectedMedicalConditions;
  bool get medicalConditionOtherSelected => _medicalConditionOtherSelected;
  String? get medicalReportName => _medicalReportName;
  String? get inBodyReportName => _inBodyReportName;

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
      // Handle "None" exclusivity
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

  /// Save profile changes
  void saveChanges(VoidCallback onSaved) {
    // In a real app, this would save to a database or service
    // For now, just navigate back
    onSaved();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherMedicalConditionController.dispose();
    super.dispose();
  }
}
