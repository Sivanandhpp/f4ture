import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Service for handling user-related Firestore operations
class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  /// Get user document reference
  static DocumentReference<Map<String, dynamic>> _userDoc(String id) {
    return _firestore.collection(_collection).doc(id);
  }

  /// Check if user exists in Firestore
  static Future<bool> userExists(String userId) async {
    final doc = await _userDoc(userId).get();
    return doc.exists;
  }

  /// Get user by ID
  static Future<UserModel?> getUser(String userId) async {
    final doc = await _userDoc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Create new user in Firestore (first-time login)
  static Future<UserModel> createUser({
    required String userId,
    required String phone,
  }) async {
    final user = UserModel(
      id: userId,
      phone: phone,
      role: 'attendee',
      status: 'active',
    );

    await _userDoc(userId).set(user.toFirestore());
    return user;
  }

  /// Update user data
  static Future<void> updateUser(UserModel user) async {
    await _userDoc(
      user.id,
    ).update({...user.toFirestore(), 'updated_at': Timestamp.now()});
  }

  /// Create user if not exists, otherwise return existing user
  static Future<UserModel> getOrCreateUser({
    required String userId,
    required String phone,
  }) async {
    final existingUser = await getUser(userId);
    if (existingUser != null) {
      return existingUser;
    }
    return createUser(userId: userId, phone: phone);
  }
}
