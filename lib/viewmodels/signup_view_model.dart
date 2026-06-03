import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';

/// viewmodel for signup screen
class SignupViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignupViewModel({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _userRepository = userRepository ?? UserRepository();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _agreedToTerms = false;

  // Kept as an alias so older tests/call sites do not break while the UI uses
  // the clearer username name.
  TextEditingController get nameController => usernameController;
  bool get agreedToTerms => _agreedToTerms;

  /// toggle terms agreement
  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  /// validate and perform signup using repositories
  Future<bool> signup(BuildContext context, VoidCallback onSuccess) async {
    // clear any previous errors
    clearError();

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setError('Please fill all fields');
      return false;
    }

    if (username.length < 3) {
      setError('Username must be at least 3 characters');
      return false;
    }

    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      setError(
        'Username can only contain letters, numbers, dots, and underscores',
      );
      return false;
    }

    if (!_isValidEmail(email)) {
      setError('Please enter a valid email address');
      return false;
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return false;
    }

    if (password != confirmPassword) {
      setError('Passwords do not match');
      return false;
    }

    // check terms agreement
    if (!_agreedToTerms) {
      setError('Please agree to Terms & Conditions');
      return false;
    }

    setLoading(true);

    try {
      // 1. create user in firebase authentication via repository
      final credential = await _authRepository.createUserWithEmailAndPassword(
        email,
        password,
      );

      final user = credential.user;

      if (user != null) {
        // 2. save additional user details (like name) to firestore via repository
        await _userRepository.updateFields(user.uid, {
          'uid': user.uid,
          'username': username,
          'name': username,
          'email': email,
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

  /// perform google login/signup
  Future<void> loginWithGoogle(
    BuildContext context,
    VoidCallback onSuccess,
  ) async {
    clearError();
    setLoading(true);

    try {
      final credential = await _authRepository.signInWithGoogle();

      // check if this is a new user and create record in firestore
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        final user = credential.user;
        if (user != null) {
          await _userRepository.updateFields(user.uid, {
            'uid': user.uid,
            'username': user.displayName ?? 'New User',
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
        return;
      }
      setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// perform apple login/signup
  Future<void> loginWithApple(
    BuildContext context,
    VoidCallback onSuccess,
  ) async {
    clearError();
    setLoading(true);

    try {
      final credential = await _authRepository.signInWithApple();

      if (credential.additionalUserInfo?.isNewUser ?? false) {
        final user = credential.user;
        if (user != null) {
          await _userRepository.updateFields(user.uid, {
            'uid': user.uid,
            'username': user.displayName ?? 'New User',
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

  /// navigate to login screen
  void navigateToLogin(VoidCallback onNavigate) {
    onNavigate();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
