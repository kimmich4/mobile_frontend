import 'package:flutter/material.dart';
import 'base_view_model.dart';

/// ViewModel for Signup Screen
class SignupViewModel extends BaseViewModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _agreedToTerms = false;

  bool get agreedToTerms => _agreedToTerms;

  /// Toggle terms agreement
  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  /// Validate and perform signup
  bool signup(BuildContext context, VoidCallback onSuccess) {
    // Clear any previous errors
    clearError();

    // Validate all fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setError('Please fill all fields');
      return false;
    }

    // Check password match
    if (passwordController.text != confirmPasswordController.text) {
      setError('Passwords do not match');
      return false;
    }

    // Check terms agreement
    if (!_agreedToTerms) {
      setError('Please agree to Terms & Conditions');
      return false;
    }

    // In a real app, this would call a registration service
    onSuccess();
    return true;
  }

  /// Navigate to login screen
  void navigateToLogin(VoidCallback onNavigate) {
    onNavigate();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
