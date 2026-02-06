import 'package:flutter/material.dart';
import 'base_view_model.dart';
import '../core/theme/theme_manager.dart';

/// ViewModel for Settings Screen
class SettingsViewModel extends BaseViewModel {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _dataSharingEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get dataSharingEnabled => _dataSharingEnabled;

  // User profile info
  final String userName = 'Mohamed Abdallah';
  final String userInitial = 'J';
  final String membershipStatus = 'Premium Member';

  /// Initialize dark mode from ThemeManager
  void initializeDarkMode() {
    _darkModeEnabled = ThemeManager.themeMode.value == ThemeMode.dark;
    notifyListeners();
  }

  /// Toggle notifications
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  /// Toggle dark mode
  void setDarkModeEnabled(bool value) {
    _darkModeEnabled = value;
    ThemeManager.toggleTheme(value);
    notifyListeners();
  }

  /// Toggle data sharing
  void setDataSharingEnabled(bool value) {
    _dataSharingEnabled = value;
    notifyListeners();
  }

  /// Navigate to a specific screen
  void navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  /// Show modal bottom sheet
  void showModal(BuildContext context, String title, String description) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(title),
      ),
    );
  }

  /// Show logout confirmation dialog
  void showLogoutDialog(BuildContext context, VoidCallback onLogout) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onLogout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Show export data dialog
  void showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(title: Text('Exporting...')),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }
}
