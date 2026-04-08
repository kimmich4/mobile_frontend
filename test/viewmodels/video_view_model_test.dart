import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/video_view_model.dart';
import 'package:mobile_frontend/data/services/api_service.dart';
import 'package:mobile_frontend/data/models/workout_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late VideoViewModel viewModel;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    viewModel = VideoViewModel(apiService: mockApiService);
  });

  group('VideoViewModel', () {
    test('init should set properties from exercise', () async {
      final exercise = Exercise(
        id: 1,
        name: 'Pushups',
        difficulty: 'Intermediate',
        equipment: 'Bodyweight',
        sets: '3',
        reps: '15',
        calories: 50,
      );

      when(() => mockApiService.searchVideo(any()))
          .thenAnswer((_) async => 'video_id_123');

      await viewModel.init(exercise);

      expect(viewModel.title, 'Pushups');
      expect(viewModel.calories, 50);
      expect(viewModel.difficulty, 'Intermediate');
      expect(viewModel.durationMinutes, 5); // 50 / 10 = 5
      expect(viewModel.keyPoints.length, 3);
    });

    test('fetchExerciseVideo should handle errors gracefully', () async {
       final exercise = Exercise(
        id: 1,
        name: 'Pushups',
        difficulty: 'Intermediate',
        equipment: 'Bodyweight',
        sets: '3',
        reps: '15',
        calories: 50,
      );

      when(() => mockApiService.searchVideo(any()))
          .thenThrow(Exception('API Error'));

      await viewModel.init(exercise);

      expect(viewModel.isVideoLoading, false);
      expect(viewModel.errorMessage != null, true);
    });
  });
}
