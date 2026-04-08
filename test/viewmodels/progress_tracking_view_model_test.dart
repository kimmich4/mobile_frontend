import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/progress_tracking_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/progress_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';
import 'package:mobile_frontend/data/repositories/diet_repository.dart';
import 'package:mobile_frontend/data/repositories/workout_repository.dart';
import 'package:mobile_frontend/data/models/progress_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockProgressRepository extends Mock implements ProgressRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockDietRepository extends Mock implements DietRepository {}
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late ProgressTrackingViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockProgressRepository mockProgressRepository;
  late MockUserRepository mockUserRepository;
  late MockDietRepository mockDietRepository;
  late MockWorkoutRepository mockWorkoutRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockProgressRepository = MockProgressRepository();
    mockUserRepository = MockUserRepository();
    mockDietRepository = MockDietRepository();
    mockWorkoutRepository = MockWorkoutRepository();
    
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  group('ProgressTrackingViewModel', () {
    test('initial state should be empty', () {
      viewModel = ProgressTrackingViewModel(
        authRepository: mockAuthRepository,
        progressRepository: mockProgressRepository,
        userRepository: mockUserRepository,
        dietRepository: mockDietRepository,
        workoutRepository: mockWorkoutRepository,
      );
      
      expect(viewModel.selectedPeriod, 0); // Week
      expect(viewModel.currentPeriod, ProgressPeriod.week);
      expect(viewModel.stats, null);
    });

    test('setSelectedPeriod should update period', () {
      viewModel = ProgressTrackingViewModel(
        authRepository: mockAuthRepository,
        progressRepository: mockProgressRepository,
        userRepository: mockUserRepository,
        dietRepository: mockDietRepository,
        workoutRepository: mockWorkoutRepository,
      );
      
      viewModel.setSelectedPeriod(1);
      expect(viewModel.selectedPeriod, 1);
      expect(viewModel.currentPeriod, ProgressPeriod.month);
    });
  });
}
