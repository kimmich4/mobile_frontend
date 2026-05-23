import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import 'base_view_model.dart';
import '../core/theme/theme_manager.dart';

/// viewmodel for settings screen
class SettingsViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  UserModel? _currentUser;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _dataSharingEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get dataSharingEnabled => _dataSharingEnabled;

  // user profile info
  String get userName => _currentUser?.fullName ?? 'User';
  String get userInitial => _currentUser?.profileInitial ?? 'U';
  String? get profilePicturePath => _currentUser?.profilePicturePath;
  String get membershipStatus => (_currentUser?.isPremiumMember ?? false) ? 'Premium Member' : 'Free Member';

  SettingsViewModel({AuthRepository? authRepository, UserRepository? userRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository() {
    _initAuthListener();
  }

  void _initAuthListener() {
    // listen to auth state changes to handle user switching
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      // cancel previous user subscription
      _userSubscription?.cancel();
      _currentUser = null;
      
      if (user != null) {
        // initialize new user stream
        _userSubscription = _userRepository.getUserStream(user.uid).listen((userModel) {
          if (userModel != null) {
            _currentUser = userModel;
            _notificationsEnabled = userModel.notificationsEnabled;
            _darkModeEnabled = userModel.darkModeEnabled;
            _dataSharingEnabled = userModel.dataSharingEnabled;
            notifyListeners();
          }
        });
      } else {
        // reset to defaults when logged out
        _notificationsEnabled = true;
        _darkModeEnabled = false;
        _dataSharingEnabled = false;
        notifyListeners();
      }
    });
  }

  /// initialize dark mode from thememanager
  void initializeDarkMode() {
    _darkModeEnabled = ThemeManager.themeMode.value == ThemeMode.dark;
    notifyListeners();
  }

  /// toggle notifications
  void setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final user = _authRepository.currentUser;
    if (user != null) {
      await _userRepository.updateFields(user.uid, {'notificationsEnabled': value});
    }
  }

  /// toggle dark mode
  void setDarkModeEnabled(bool value) async {
    _darkModeEnabled = value;
    ThemeManager.toggleTheme(value);
    notifyListeners();
    final user = _authRepository.currentUser;
    if (user != null) {
      await _userRepository.updateFields(user.uid, {'darkModeEnabled': value});
    }
  }

  /// toggle data sharing
  void setDataSharingEnabled(bool value) async {
    _dataSharingEnabled = value;
    notifyListeners();
    final user = _authRepository.currentUser;
    if (user != null) {
      await _userRepository.updateFields(user.uid, {'dataSharingEnabled': value});
    }
  }

  /// navigate to a specific screen
  void navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// show modal bottom sheet
  void showModal(BuildContext context, String title, String description) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(description),
          ],
        ),
      ),
    );
  }

  /// show logout confirmation dialog
  void showLogoutDialog(BuildContext context, VoidCallback onLogout) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authRepository.signOut();
              onLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// show export data dialog
  void showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(title: Text('Exporting...'), content: Text('Generating your health report...')),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
