import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/edit_profile_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late EditProfileViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
  });

  group('EditProfileViewModel', () {
    test('initial state when user not found should be empty', () {
      viewModel = EditProfileViewModel(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
      
      expect(viewModel.nameController.text, '');
      expect(viewModel.selectedGender, 'Male');
    });

    test('toggleMedicalCondition should update state', () {
      viewModel = EditProfileViewModel(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
      
      viewModel.toggleMedicalCondition('Asthma');
      expect(viewModel.selectedMedicalConditions.contains('Asthma'), true);
    });
  });
}
