import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_frontend/viewmodels/auth_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockBuildContext extends Mock implements BuildContext {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockBuildContext mockContext;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockContext = MockBuildContext();
    viewModel = AuthViewModel(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
    );
  });

  group('AuthViewModel', () {
    test('login should fail if email and password are empty', () async {
      final result = await viewModel.login(mockContext, () {});
      
      expect(result, false);
      expect(viewModel.error, 'Please enter email and password');
    });

    test('login should succeed and call onSuccess on valid credentials', () async {
      viewModel.emailController.text = 'test@example.com';
      viewModel.passwordController.text = 'password123';
      
      when(() => mockAuthRepository.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => mockUserCredential());

      bool successCalled = false;
      final result = await viewModel.login(mockContext, () {
        successCalled = true;
      });

      expect(result, true);
      expect(successCalled, true);
      expect(viewModel.isLoading, false);
    });

    test('login should set error on repository exception', () async {
      viewModel.emailController.text = 'test@example.com';
      viewModel.passwordController.text = 'password123';
      
      when(() => mockAuthRepository.signInWithEmailAndPassword(any(), any()))
          .thenThrow(Exception('user-not-found'));

      final result = await viewModel.login(mockContext, () {});

      expect(result, false);
      expect(viewModel.error, 'No user found for that email.');
    });
  });
}

// Helper to mock UserCredential if needed
MockUserCredential mockUserCredential() {
  return MockUserCredential();
}
