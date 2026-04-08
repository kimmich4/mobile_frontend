import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// ViewModel for Authentication (Login) Screen
class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthViewModel({AuthRepository? authRepository, UserRepository? userRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository();

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

  /// Perform Google Login
  Future<void> loginWithGoogle(BuildContext context, VoidCallback onSuccess) async {
    clearError();
    setLoading(true);

    try {
      final credential = await _authRepository.signInWithGoogle();
      
      // Check if this is a new user and create record in Firestore if needed
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        final user = credential.user;
        if (user != null) {
          await _userRepository.updateFields(user.uid, {
            'uid': user.uid,
            'name': user.displayName ?? 'New User',
            'email': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      setLoading(false);
      onSuccess();
    } on Exception catch (e) {
      setLoading(false);
      if (e.toString().contains('canceled')) {
        return; // Don't show error if user just closed the popup
      }
      setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Perform Apple Login
  Future<void> loginWithApple(BuildContext context, VoidCallback onSuccess) async {
    clearError();
    setLoading(true);

    try {
      final credential = await _authRepository.signInWithApple();

      // Check if this is a new user
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        final user = credential.user;
        if (user != null) {
          await _userRepository.updateFields(user.uid, {
            'uid': user.uid,
            'name': user.displayName ?? 'New User',
            'email': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      setLoading(false);
      onSuccess();
    } on Exception catch (e) {
      setLoading(false);
      setError(e.toString().replaceFirst('Exception: ', ''));
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
