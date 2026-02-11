import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// ViewModel for Signup Screen
class SignupViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  
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

  /// Validate and perform signup using repositories
  Future<bool> signup(BuildContext context, VoidCallback onSuccess) async {
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

    setLoading(true);

    try {
      // 1. Create user in Firebase Authentication via Repository
      final credential = await _authRepository.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      final user = credential.user;

      if (user != null) {
        // 2. Save additional user details (like name) to Firestore via Repository
        await _userRepository.updateFields(user.uid, {
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        setLoading(false);
        onSuccess();
        return true;
      }

      setLoading(false);
      setError('Failed to create user');
      return false;

    } on Exception catch (e) {
      setLoading(false);
      final message = e.toString();
      if (message.contains('weak-password')) {
        setError('The password provided is too weak.');
      } else if (message.contains('email-already-in-use')) {
        setError('The account already exists for that email.');
      } else if (message.contains('invalid-email')) {
        setError('The email address is not valid.');
      } else {
        setError(message.replaceFirst('Exception: ', ''));
      }
      return false;
    }
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
