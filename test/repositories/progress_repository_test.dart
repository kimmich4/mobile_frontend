import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mobile_frontend/data/repositories/progress_repository.dart';
import 'package:mobile_frontend/data/models/progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late ProgressRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ProgressRepository(firestore: fakeFirestore);
  });

  group('ProgressRepository', () {
    test('fetchWeightLogsForPeriod returns points from Firestore', () async {
      final now = DateTime.now();
      await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('weightLogs')
          .add({
        'trackedWeightKg': 80.0,
        'loggedAt': Timestamp.fromDate(now),
      });

      final results = await repository.fetchWeightLogsForPeriod('user123', ProgressPeriod.week);
      
      expect(results.length, 1);
      expect(results.first.weight, 80.0);
    });

    test('logWorkoutCompletion saves to dailyLogs', () async {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      
      await repository.logWorkoutCompletion(
        'user123',
        'Mon',
        true,
        caloriesBurned: 320,
      );
      
      final doc = await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('dailyLogs')
          .doc(todayStr)
          .get();
          
      expect(doc.exists, true);
      expect(doc.data()?['workoutCompleted'], true);
      expect(doc.data()?['caloriesBurned'], 320);
    });

    test('logCalorieConsumption saves caloriesConsumed to dailyLogs', () async {
      final todayStr = DateTime.now().toIso8601String().split('T').first;

      await repository.logCalorieConsumption('user123', 1850);

      final doc = await fakeFirestore
          .collection('users')
          .doc('user123')
          .collection('dailyLogs')
          .doc(todayStr)
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['caloriesConsumed'], 1850);
    });
  });
}
