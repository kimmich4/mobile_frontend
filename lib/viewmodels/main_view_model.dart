import 'base_view_model.dart';

/// ViewModel for Main Screen with bottom navigation
class MainViewModel extends BaseViewModel {
  int _selectedIndex = 0;
  static MainViewModel? _instance;

  int get selectedIndex => _selectedIndex;

  /// Set the singleton instance
  void setInstance() {
    _instance = this;
  }

  /// Clear the singleton instance
  void clearInstance() {
    if (_instance == this) {
      _instance = null;
    }
  }

  /// Switch to a specific tab
  void switchTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Static method to switch tab from anywhere (maintains existing behavior)
  static void switchTabStatic(int index) {
    _instance?.switchTab(index);
  }

  @override
  void dispose() {
    clearInstance();
    super.dispose();
  }
}
