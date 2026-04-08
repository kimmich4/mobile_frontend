import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/data/repositories/workout_repository.dart';
import 'package:mobile_frontend/data/services/api_service.dart';
import 'package:mobile_frontend/data/models/workout_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late WorkoutRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockApiService mockApiService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockApiService = MockApiService();
    repository = WorkoutRepository(firestore: fakeFirestore, apiService: mockApiService);
  });

  group('WorkoutRepository', () {
    test('generateAndSaveWorkoutPlans saves both gym and home plans', () async {
      final gymPlan = WorkoutPlan(title: 'Gym', days: []);
      final homePlan = WorkoutPlan(title: 'Home', days: []);
      
      when(() => mockApiService.generateWorkoutPlans(
            userId: any(named: 'userId'),
            userProfile: any(named: 'userProfile'),
          )).thenAnswer((_) async => {'gym': gymPlan, 'home': homePlan});

      await repository.generateAndSaveWorkoutPlans(
        userId: 'user123',
        userProfile: {},
      );

      final gymDoc = await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('workoutPlans')
          .doc('gym_workout')
          .get();
          
      final homeDoc = await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('workoutPlans')
          .doc('home_workout')
          .get();

      expect(gymDoc.exists, true);
      expect(homeDoc.exists, true);
    });
  });
}
