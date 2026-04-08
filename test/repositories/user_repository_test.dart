import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mobile_frontend/data/repositories/user_repository.dart';
import 'package:mobile_frontend/data/models/user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late UserRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockStorage;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    repository = UserRepository(
      firestore: fakeFirestore,
      storage: mockStorage,
    );
  });

  group('UserRepository', () {
    test('saveUserProfile should save user data in Firestore', () async {
      final user = UserModel(
        userId: 'user123',
        email: 'test@test.com',
        fullName: 'Test User',
      );

      await repository.saveUserProfile(user);

      final doc = await fakeFirestore.collection('users').doc('user123').get();
      expect(doc.exists, true);
      expect(doc.data()?['email'], 'test@test.com');
      expect(doc.data()?['fullName'], 'Test User');
    });

    test('getUserProfile should retrieve user from Firestore', () async {
      await fakeFirestore.collection('users').doc('user123').set({
        'userId': 'user123',
        'email': 'get@test.com',
        'fullName': 'Get User',
      });

      final result = await repository.getUserProfile('user123');

      expect(result, isNotNull);
      expect(result!.email, 'get@test.com');
      expect(result.fullName, 'Get User');
    });

    test('getUserStream should return real-time updates', () async {
      final ref = fakeFirestore.collection('users').doc('user123');
      await ref.set({'fullName': 'Initial'});

      final stream = repository.getUserStream('user123');
      
      expect(
        stream,
        emitsInOrder([
          predicate<UserModel?>((u) => u?.fullName == 'Initial'),
          predicate<UserModel?>((u) => u?.fullName == 'Updated'),
        ]),
      );

      await ref.update({'fullName': 'Updated'});
    });
  });
}
