import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/profile_setup_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';
import 'package:mobile_frontend/data/repositories/diet_repository.dart';
import 'package:mobile_frontend/data/repositories/workout_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockDietRepository extends Mock implements DietRepository {}
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late ProfileSetupViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockDietRepository mockDietRepository;
  late MockWorkoutRepository mockWorkoutRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockDietRepository = MockDietRepository();
    mockWorkoutRepository = MockWorkoutRepository();
    
    viewModel = ProfileSetupViewModel(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
      dietRepository: mockDietRepository,
      workoutRepository: mockWorkoutRepository,
    );
  });

  group('ProfileSetupViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.currentPage, 0);
      expect(viewModel.selectedGender, 'Male');
      expect(viewModel.progressPercentage, 0.25);
    });

    test('setCurrentPage should update state', () {
      viewModel.setCurrentPage(2);
      expect(viewModel.currentPage, 2);
      expect(viewModel.progressPercentage, 0.75);
    });

    test('setSelectedGender should update state', () {
      viewModel.setSelectedGender('Female');
      expect(viewModel.selectedGender, 'Female');
    });

    test('toggleMedicalCondition should add/remove item', () {
      viewModel.toggleMedicalCondition('Diabetes');
      expect(viewModel.selectedMedicalConditions.contains('Diabetes'), true);
      
      viewModel.toggleMedicalCondition('Diabetes');
      expect(viewModel.selectedMedicalConditions.contains('Diabetes'), false);
    });

    test('toggleMedicalCondition with None should clear others', () {
      viewModel.toggleMedicalCondition('Diabetes');
      viewModel.toggleMedicalCondition('None');
      expect(viewModel.selectedMedicalConditions.length, 1);
      expect(viewModel.selectedMedicalConditions.first, 'None');
    });
  });
}
