import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../routes/app_pages.dart';

/// Global Authentication Controller
/// Manages auth state and persistence across app sessions
class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // Storage keys
  static const String _isLoggedInKey = 'isLoggedIn';

  // Reactive state
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind to Firebase auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthStateChange);

    // Load initial state from storage
    isLoggedIn.value = _storage.read<bool>(_isLoggedInKey) ?? false;
  }

  /// Handle Firebase auth state changes
  void _handleAuthStateChange(User? user) {
    if (user != null) {
      // User is signed in
      isLoggedIn.value = true;
      _storage.write(_isLoggedInKey, true);
    } else {
      // User is signed out
      isLoggedIn.value = false;
      _storage.write(_isLoggedInKey, false);
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _storage.write(_isLoggedInKey, false);
      isLoggedIn.value = false;

      // Navigate to authentication screen
      Get.offAllNamed(Routes.AUTHENTICATION);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
