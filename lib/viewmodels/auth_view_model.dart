import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// viewmodel for authentication (login) screen
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

  /// validate input and perform login using repository
  Future<bool> login(BuildContext context, VoidCallback onSuccess) async {
    // clear any previous errors
    clearError();

    // validate input
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
      // we can improve error parsing in the repository or here
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

  /// perform google login
  Future<void> loginWithGoogle(BuildContext context, VoidCallback onSuccess) async {
    clearError();
    setLoading(true);

    try {
      final credential = await _authRepository.signInWithGoogle();
      
      // check if this is a new user and create record in firestore if needed
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
        return; // don't show error if user just closed the popup
      }
      setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// perform apple login
  Future<void> loginWithApple(BuildContext context, VoidCallback onSuccess) async {
    clearError();
    setLoading(true);

    try {
      final credential = await _authRepository.signInWithApple();

      // check if this is a new user
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


  /// navigate to signup screen
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
