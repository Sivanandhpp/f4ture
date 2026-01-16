import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/services/notification_service.dart';

import '../../routes/app_pages.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _box = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Scopes are often configured in the Google Cloud Console / Firebase,
  // but if needed we can pass them to a constructor if one existed.
  // With .instance, scopes might need to be set via initialize if supported,
  // or generally defaults are fine for Firebase Auth (profile/email).

  // Use the singleton instance as required by latest version
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Observable User State
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;

  StreamSubscription<User?>? _authSubscription;

  // We rely on FirebaseAuth stream for session management.
  // GoogleSignIn stream is optional if we just use it for manual sign-in.

  @override
  void onInit() {
    super.onInit();
    // Initialize from local cache
    _loadUserFromCache();
    // Start listening to Firebase Auth changes
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  // --- State Management ---

  void _loadUserFromCache() {
    try {
      final userData = _box.read('user');
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }
    } catch (e) {
      Get.log('AuthService: Error loading user from cache: $e', isError: true);
    }
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    isLoading.value = true;
    if (firebaseUser == null) {
      currentUser.value = null;
      await _box.remove('user');
      isLoading.value = false;
    } else {
      await _syncUserProfile(firebaseUser.uid);
      isLoading.value = false;

      if (Get.isRegistered<NotificationService>()) {
        try {
          Get.find<NotificationService>().init();
        } catch (e) {
          Get.log('AuthService: Failed to init notifications: $e');
        }
      }
    }
  }

  Future<void> _syncUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromJson(doc.data()!);
        await saveUser(userModel);
      } else {
        Get.log('AuthService: User authenticated but no profile found.');
      }
    } catch (e) {
      Get.log('AuthService: Error syncing user profile: $e', isError: true);
    }
  }

  Future<void> saveUser(UserModel user) async {
    currentUser.value = user;
    await _box.write('user', user.toJson());
  }

  // --- Auth Actions ---

  Future<void> clearUser() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      Get.log('AuthService: Error signing out: $e', isError: true);
      rethrow;
    }
  }

  /// Calls Cloud Function to check if email exists.
  Future<bool> checkUserExistence(String email) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'checkEmailExists',
      );
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'email': email,
      });

      if (result.data != null &&
          result.data is Map &&
          result.data['exists'] != null) {
        return result.data['exists'] as bool;
      }
      if (result.data is Map && (result.data as Map).containsKey('exists')) {
        return (result.data as Map)['exists'] as bool;
      }
      return false;
    } on FirebaseFunctionsException catch (e) {
      Get.log('AuthService: Function Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      Get.log('AuthService: Generic Check Exists Error: $e');
      return false;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Login failed. Please try again.';
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Sign up failed. Please try again.';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use authenticate() as requested by user / latest API
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken:
            null, // accessToken might be missing/null in latest implicit flow
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      Get.log('AuthService: Google Sign In Error: $e');
      throw 'Google Sign In failed.';
    }
  }

  // --- Helpers ---

  String _handleAuthError(FirebaseAuthException e) {
    Get.log('AuthService: FirebaseAuthException: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  String determineInitialRoute() {
    final user = currentUser.value;
    final firebaseUser = _auth.currentUser;

    if (user != null) {
      return Routes.ATTENDEE;
    }

    if (firebaseUser != null) {
      return Routes.AUTHENTICATION;
    }

    return Routes.AUTHENTICATION;
  }
}
