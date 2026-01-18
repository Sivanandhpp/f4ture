import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

enum AuthStep { emailInput, passwordInput }

class AuthenticationController extends GetxController {
  final AuthService _authService = AuthService.to;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final Rx<AuthStep> currentStep = AuthStep.emailInput.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void resetFlow() {
    currentStep.value = AuthStep.emailInput;
    emailController.clear();
    passwordController.clear();
  }

  Future<void> onContinue() async {
    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    if (currentStep.value == AuthStep.emailInput) {
      await _checkEmail(email);
    } else {
      await _loginWithPassword(email);
    }
  }

  Future<void> _checkEmail(String email) async {
    isLoading.value = true;
    try {
      // Use efficient Cloud Function check
      final exists = await _authService.checkUserExistence(email);
      isLoading.value = false;

      if (exists) {
        // Existing User -> Ask for password
        currentStep.value = AuthStep.passwordInput;
      } else {
        // New User -> Redirect to Details (Registration)
        Get.toNamed(Routes.USER_DETAILS, arguments: {'email': email});
      }
    } catch (e) {
      isLoading.value = false;
      // Fallback: ask for password if check fails
      print('Check Email Failed: $e');
      currentStep.value = AuthStep.passwordInput;
    }
  }

  Future<void> _loginWithPassword(String email) async {
    final password = passwordController.text;
    if (password.isEmpty) {
      Get.snackbar('Error', 'Please enter your password');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signInWithEmail(email, password);
      await _handleAuthSuccess();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Login Failed', e.message ?? 'Unknown error');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        await _handleAuthSuccess(isGoogle: true);
      } else {
        isLoading.value = false; // User cancelled
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Google Sign-In Failed', e.toString());
    }
  }

  Future<void> _handleAuthSuccess({bool isGoogle = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      isLoading.value = false;

      if (doc.exists && doc.data() != null) {
        // Existing User -> Load and Check Status
        final userModel = UserModel.fromJson(doc.data()!);

        if (userModel.status == 'inactive') {
          await _authService.clearUser();
          Get.offAllNamed(Routes.BLOCKED, arguments: userModel);
          return;
        }

        await _authService.saveUser(userModel);
        Get.offAllNamed(Routes.NAVIGATION);
      } else {
        // New User (via Google) or Incomplete Registration -> User Details
        Get.offAllNamed(
          Routes.USER_DETAILS,
          arguments: {
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'isGoogle': isGoogle,
          },
        );
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(email);
      isLoading.value = false;

      // iOS Style Popup
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Password Reset',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Password reset mail sent to $email. Check spam if not found.',
            style: const TextStyle(color: Colors.white70),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> reactivateAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Use set with merge true to just update status and remove deletedAt
        // Actually update is safer to not overwrite other fields unintentionally if doc is missing (it shouldn't be)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'status': 'active', 'deletedAt': FieldValue.delete()});

        await _authService.refreshUser(); // Refresh local user model
        Get.offAllNamed(Routes.NAVIGATION);

        Get.snackbar(
          'Welcome Back!',
          'Your account has been reactivated.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reactivate account: $e');
    }
  }

  Future<void> logout() async {
    await _authService.clearUser();
    Get.offAllNamed(Routes.AUTHENTICATION);
  }
}
