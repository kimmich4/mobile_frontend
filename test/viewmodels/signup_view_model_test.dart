import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_frontend/viewmodels/signup_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockBuildContext extends Mock implements BuildContext {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late SignupViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockBuildContext mockContext;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockContext = MockBuildContext();
    viewModel = SignupViewModel(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
    );
  });

  group('SignupViewModel', () {
    test('signup fails if fields are empty', () async {
      final result = await viewModel.signup(mockContext, () {});
      expect(result, false);
      expect(viewModel.error, 'Please fill all fields');
    });

    test('signup fails if passwords do not match', () async {
      viewModel.nameController.text = 'Name';
      viewModel.emailController.text = 'test@test.com';
      viewModel.passwordController.text = 'pass123';
      viewModel.confirmPasswordController.text = 'pass456';
      
      final result = await viewModel.signup(mockContext, () {});
      expect(result, false);
      expect(viewModel.error, 'Passwords do not match');
    });

    test('signup fails if terms not agreed', () async {
      viewModel.nameController.text = 'Name';
      viewModel.emailController.text = 'test@test.com';
      viewModel.passwordController.text = 'pass123';
      viewModel.confirmPasswordController.text = 'pass123';
      
      final result = await viewModel.signup(mockContext, () {});
      expect(result, false);
      expect(viewModel.error, 'Please agree to Terms & Conditions');
    });
  });
}
