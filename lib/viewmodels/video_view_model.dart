import 'base_view_model.dart';

/// ViewModel for Video Screen
class VideoViewModel extends BaseViewModel {
  // Video details
  final String title = 'Push-ups Tutorial';
  final String difficulty = 'Beginner';
  final int durationMinutes = 10;

  // Key points
  final List<String> keyPoints = [
    'Keep your core engaged throughout the movement',
    'Maintain proper breathing pattern',
    'Focus on controlled, smooth movements',
  ];

  // Common mistakes
  final List<String> commonMistakes = [
    'Arching your back excessively',
    'Holding your breath too long',
  ];

  /// Toggle AR guide (placeholder for future functionality)
  void toggleArGuide() {
    // In a real app, this would enable AR posture guidance
    notifyListeners();
  }

  /// Play/pause video (placeholder for future functionality)
  void togglePlayPause() {
    // In a real app, this would control video playback
    notifyListeners();
  }
}
