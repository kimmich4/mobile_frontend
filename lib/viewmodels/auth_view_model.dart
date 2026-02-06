import 'package:flutter/material.dart';
import 'base_view_model.dart';

/// ViewModel for Authentication (Login) Screen
class AuthViewModel extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String get email => emailController.text;
  String get password => passwordController.text;

  /// Validate input and perform login
  bool login(BuildContext context, VoidCallback onSuccess) {
    // Clear any previous errors
    clearError();

    // Validate input
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setError('Please enter email and password');
      return false;
    }

    // In a real app, this would call an authentication service
    // For now, just navigate to main screen
    onSuccess();
    return true;
  }

  /// Navigate to signup screen
  void navigateToSignup(VoidCallback onNavigate) {
    onNavigate();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
