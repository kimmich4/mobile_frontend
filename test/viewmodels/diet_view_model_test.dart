import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';
import 'package:mobile_frontend/viewmodels/diet_view_model.dart';
import 'package:mobile_frontend/data/repositories/diet_repository.dart';
import 'package:mobile_frontend/data/repositories/progress_repository.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';
import 'package:mobile_frontend/data/models/diet_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDietRepository extends Mock implements DietRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockProgressRepository extends Mock implements ProgressRepository {}
class MockUser extends Mock implements User {}

void main() {
  late DietViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockDietRepository mockDietRepository;
  late MockUserRepository mockUserRepository;
  late MockProgressRepository mockProgressRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockDietRepository = MockDietRepository();
    mockUserRepository = MockUserRepository();
    mockProgressRepository = MockProgressRepository();
    
    when(() => mockAuthRepository.currentUser).thenReturn(null);

    viewModel = DietViewModel(
      authRepository: mockAuthRepository,
      dietRepository: mockDietRepository,
      userRepository: mockUserRepository,
      progressRepository: mockProgressRepository,
    );
  });

  group('DietViewModel', () {
    test('selectDay should update selectedDayIndex', () {
      viewModel.selectDay(3);
      expect(viewModel.selectedDayIndex, 3);
    });

    test('fetchDietPlan should set diet plan on success', () async {
      final mockFirebaseUser = MockUser();
      final mockPlan = DietPlan(days: []);

      when(() => mockFirebaseUser.uid).thenReturn('user123');
      when(() => mockAuthRepository.currentUser).thenReturn(mockFirebaseUser);
      when(() => mockDietRepository.getDietPlan('user123'))
          .thenAnswer((_) async => mockPlan);

      await viewModel.fetchDietPlan();

      expect(viewModel.dietPlan, mockPlan);
      expect(viewModel.isLoading, false);
      verify(() => mockDietRepository.getDietPlan('user123')).called(1);
    });

    test('getFormattedDate returns correct string', () {
      viewModel.selectDay(0);
      expect(viewModel.getFormattedDate(), 'Weekly Plan - Day 1');
      
      viewModel.selectDay(6);
      expect(viewModel.getFormattedDate(), 'Weekly Plan - Day 7');
    });
  });
}
