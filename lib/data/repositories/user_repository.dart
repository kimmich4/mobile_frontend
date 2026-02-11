import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository handling all Firestore operations for User profiles
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update a full user profile
  Future<void> saveUserProfile(UserModel user) async {
    if (user.userId == null) throw Exception('User ID is required to save profile');
    
    await _firestore.collection('users').doc(user.userId).set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  /// Get a user profile by UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Get a user profile by UID as a stream for real-time updates
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Update specific fields in a user profile
  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(
          data,
          SetOptions(merge: true),
        );
  }
}
