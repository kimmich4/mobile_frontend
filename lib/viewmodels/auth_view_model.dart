import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import 'base_view_model.dart';

/// ViewModel for Authentication (Login) Screen
class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String get email => emailController.text;
  String get password => passwordController.text;

  /// Validate input and perform login using repository
  Future<bool> login(BuildContext context, VoidCallback onSuccess) async {
    // Clear any previous errors
    clearError();

    // Validate input
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setError('Please enter email and password');
      return false;
    }

    setLoading(true);

    try {
      await _authRepository.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      setLoading(false);
      onSuccess();
      return true;

    } on Exception catch (e) {
      setLoading(false);
      // We can improve error parsing in the repository or here
      final message = e.toString();
      if (message.contains('user-not-found')) {
        setError('No user found for that email.');
      } else if (message.contains('wrong-password')) {
        setError('Wrong password provided for that user.');
      } else if (message.contains('invalid-email')) {
        setError('The email address is not valid.');
      } else {
        setError(message.replaceFirst('Exception: ', ''));
      }
      return false;
    }
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
