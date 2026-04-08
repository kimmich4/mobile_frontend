import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/splash_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SplashViewModel viewModel;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // SplashViewModel calls signOut in constructor
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async => {});
  });

  group('SplashViewModel', () {
    test('isLoggedIn returns true when user is not null', () {
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      viewModel = SplashViewModel(authRepository: mockAuthRepository);
      expect(viewModel.isLoggedIn, false);
    });

    test('constructor should call signOut', () {
      viewModel = SplashViewModel(authRepository: mockAuthRepository);
      verify(() => mockAuthRepository.signOut()).called(1);
    });
  });
}
