import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/user_model.dart';

/// Repository handling all Firestore operations for User profiles
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  /// Upload profile picture to Firebase Storage and return download URL
  /// Works on both mobile and web platforms
  Future<String> uploadProfilePicture(String uid, List<int> fileBytes, String fileName) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      
      // Upload file bytes (works on both web and mobile)
      await ref.putData(
        fileBytes as Uint8List,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      // Update user profile with new picture URL
      await updateFields(uid, {'profilePicturePath': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
