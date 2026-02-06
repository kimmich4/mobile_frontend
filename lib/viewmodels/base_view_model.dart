import 'package:flutter/foundation.dart';

/// Base ViewModel class that all ViewModels should extend
/// Provides common functionality like loading state and error handling
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDisposed => _disposed;

  /// Set loading state and notify listeners
  void setLoading(bool value) {
    if (_disposed) return;
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void setError(String? value) {
    if (_disposed) return;
    _error = value;
    notifyListeners();
  }

  /// Clear any error messages
  void clearError() {
    if (_disposed) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
