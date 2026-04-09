import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_frontend/data/repositories/auth_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late AuthRepository repository;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    repository = AuthRepository(auth: mockAuth, googleSignIn: mockGoogleSignIn);
  });

  group('AuthRepository', () {
    test('currentUser should return value from firebase', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(repository.currentUser, mockUser);
    });

    test('signInWithEmailAndPassword should call firebase', () async {
      final mockCredential = MockUserCredential();
      when(() => mockAuth.signInWithEmailAndPassword(email: 'test', password: 'pass'))
          .thenAnswer((_) async => mockCredential);

      final result = await repository.signInWithEmailAndPassword('test', 'pass');
      expect(result, mockCredential);
      verify(() => mockAuth.signInWithEmailAndPassword(email: 'test', password: 'pass')).called(1);
    });

    test('signOut should call firebase', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      await repository.signOut();
      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}
