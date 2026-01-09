import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class AuthenticationController extends GetxController {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Text controllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // State
  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final phoneNumber = ''.obs;

  // Verification ID for OTP
  String _verificationId = '';

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Send OTP to phone number using Firebase
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.length < 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final fullPhoneNumber = '+91$phone';

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          e.message ?? 'Verification failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        phoneNumber.value = phone;
        isOtpSent.value = true;
        isLoading.value = false;
        Get.snackbar(
          'OTP Sent',
          'OTP sent to $fullPhoneNumber',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  /// Verify OTP using Firebase
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _signInWithCredential(credential);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in with phone credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Phone verified successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to home screen
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Authentication failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Edit phone number (go back to phone input)
  void editPhoneNumber() {
    isOtpSent.value = false;
    otpController.clear();
    _verificationId = '';
  }

  /// Check if user is already logged in
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
