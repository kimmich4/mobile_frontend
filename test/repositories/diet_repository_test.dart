import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/data/repositories/diet_repository.dart';
import 'package:mobile_frontend/data/services/api_service.dart';
import 'package:mobile_frontend/data/models/diet_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late DietRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockApiService mockApiService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockApiService = MockApiService();
    repository = DietRepository(firestore: fakeFirestore, apiService: mockApiService);
  });

  group('DietRepository', () {
    test('generateAndSaveDietPlan fetches from API and saves to Firestore', () async {
      final mockPlan = DietPlan(days: []);
      when(() => mockApiService.generateDietPlan(
            userId: any(named: 'userId'),
            userProfile: any(named: 'userProfile'),
          )).thenAnswer((_) async => mockPlan);

      final result = await repository.generateAndSaveDietPlan(
        userId: 'user123',
        userProfile: {'name': 'Test'},
      );

      expect(result, mockPlan);
      
      final doc = await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('dietPlans')
          .doc('weekly_diet')
          .get();
      
      expect(doc.exists, true);
    });

    test('getDietPlan fetches saved plan', () async {
      final dietData = {'days': []};
      await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('dietPlans')
          .doc('weekly_diet')
          .set(dietData);

      final result = await repository.getDietPlan('user123');
      expect(result, isNotNull);
    });
  });
}
