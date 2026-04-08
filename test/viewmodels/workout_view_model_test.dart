import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/viewmodels/workout_view_model.dart';
import 'package:mobile_frontend/data/repositories/workout_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';
import 'package:mobile_frontend/data/repositories/progress_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockWorkoutRepository extends Mock implements WorkoutRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late WorkoutViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockWorkoutRepository mockWorkoutRepository;
  late MockUserRepository mockUserRepository;
  late MockProgressRepository mockProgressRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockWorkoutRepository = MockWorkoutRepository();
    mockUserRepository = MockUserRepository();
    mockProgressRepository = MockProgressRepository();
    
    when(() => mockAuthRepository.currentUser).thenReturn(null);

    viewModel = WorkoutViewModel(
      authRepository: mockAuthRepository,
      workoutRepository: mockWorkoutRepository,
      userRepository: mockUserRepository,
      progressRepository: mockProgressRepository,
    );
  });

  group('WorkoutViewModel', () {
    test('setSelectedTab should update active tab', () {
      viewModel.setSelectedTab(1);
      expect(viewModel.selectedTab, 1);
    });

    test('setSelectedDay should update active day', () {
      viewModel.setSelectedDay(3);
      expect(viewModel.selectedDay, 3);
    });

    test('durationMinutes should return correct estimate based on exercise count', () {
      // Logic is currentWorkoutExercises.length * 8
      // If no plan, count is 0
      expect(viewModel.durationMinutes, 0);
    });
  });
}
