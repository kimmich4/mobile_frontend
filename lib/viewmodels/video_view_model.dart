import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'base_view_model.dart';
import '../data/models/workout_model.dart';
import '../data/services/api_service.dart';

/// ViewModel for Video Screen
class VideoViewModel extends BaseViewModel {
  // Video details
  String _title = 'Loading...';
  String _difficulty = 'Beginner';
  int _durationMinutes = 0;
  int _calories = 0;

  String get title => _title;
  String get difficulty => _difficulty;
  int get durationMinutes => _durationMinutes;
  int get calories => _calories;

  // Youtube Details
  YoutubePlayerController? _youtubeController;
  YoutubePlayerController? get youtubeController => _youtubeController;
  bool _isVideoLoading = true;
  bool get isVideoLoading => _isVideoLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Dynamic Key points
  List<String> _keyPoints = [];
  List<String> get keyPoints => _keyPoints;

  // Common mistakes (Static fallback or dynamic)
  final List<String> commonMistakes = [
    'Rushing the movement',
    'Not using full range of motion',
    'Forgetting to breathe consistently',
  ];

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  /// Initialize with a specific exercise
  Future<void> init(Exercise exercise) async {
    _title = exercise.name;
    _difficulty = exercise.difficulty;
    _durationMinutes = (exercise.calories / 10).ceil(); // Rough estimate
    _calories = exercise.calories;
    
    // Auto-generate some basic tips from the name
    _keyPoints = [
      'Focus on the mind-muscle connection for $_title',
      'Keep your core engaged during the set',
      'If you feel sharp pain, stop immediately',
    ];

    notifyListeners();
    await _fetchExerciseVideo(exercise.name);
  }

  Future<void> _fetchExerciseVideo(String exerciseName) async {
    _isVideoLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      // Search for the exercise name + "form tutoriall"
      final searchQuery = '$exerciseName exercise form tutorial';
      
      final videoId = await apiService.searchVideo(searchQuery);

      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: true,
        ),
      );
    } catch (e) {
      _errorMessage = 'Could not find a video tutorial for this exercise.';
    } finally {
      _isVideoLoading = false;
      notifyListeners();
    }
  }

}

