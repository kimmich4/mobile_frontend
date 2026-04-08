import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/settings_view_model.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late SettingsViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
  });

  group('SettingsViewModel', () {
    test('defaults should be correct', () {
      // We'll test the getters that don't depend on complex streams
      viewModel = SettingsViewModel(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
      
      expect(viewModel.notificationsEnabled, true);
      expect(viewModel.darkModeEnabled, false);
      expect(viewModel.dataSharingEnabled, false);
      expect(viewModel.userName, 'User');
    });
  });
}
