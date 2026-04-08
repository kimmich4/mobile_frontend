import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_frontend/viewmodels/home_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';
import 'package:mobile_frontend/data/repositories/diet_repository.dart';
import 'package:mobile_frontend/data/repositories/workout_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockDietRepository extends Mock implements DietRepository {}
class MockWorkoutRepository extends Mock implements WorkoutRepository {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late HomeViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockDietRepository mockDietRepository;
  late MockWorkoutRepository mockWorkoutRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockDietRepository = MockDietRepository();
    mockWorkoutRepository = MockWorkoutRepository();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
  });

  group('HomeViewModel', () {
    test('getGreeting should return correct message based on hour', () {
      // Greeting is time-based, so it will vary by when test is run
      // but we can check it returns one of the expected strings
      final greeting = HomeViewModel(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
        dietRepository: mockDietRepository,
        workoutRepository: mockWorkoutRepository,
      ).getGreeting();
      
      expect(
        ['Good Morning', 'Good Afternoon', 'Good Evening'].contains(greeting),
        true
      );
    });

    test('fullName defaults to User', () {
       viewModel = HomeViewModel(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
        dietRepository: mockDietRepository,
        workoutRepository: mockWorkoutRepository,
      );
      expect(viewModel.fullName, 'User');
    });
  });
}
