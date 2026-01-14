import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthenticationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final RxString phoneNumber = ''.obs;
  final RxString verificationId = ''.obs;
  final RxBool isOtpSent = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void editPhoneNumber() {
    isOtpSent.value = false;
    otpController.clear();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return;
    }

    isLoading.value = true;
    // Assume +91 for now, or user can add it.
    // The UI shows prefix +91, so we should append it.
    final fullPhoneNumber = '+91$phone';
    phoneNumber.value = fullPhoneNumber;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android
          await _auth.signInWithCredential(credential);
          _onAuthSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar('Verification Failed', e.message ?? 'Unknown error');
        },
        codeSent: (String vid, int? resendToken) {
          verificationId.value = vid;
          isOtpSent.value = true;
          isLoading.value = false;
          Get.snackbar('OTP Sent', 'Code sent to $fullPhoneNumber');
        },
        codeAutoRetrievalTimeout: (String vid) {
          verificationId.value = vid;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    isLoading.value = true;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      _onAuthSuccess();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Invalid OTP', e.message ?? 'Please try again');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  void _onAuthSuccess() async {
    print('DEBUG: _onAuthSuccess started');
    final user = _auth.currentUser;
    if (user != null) {
      print('DEBUG: User is signed in: ${user.uid}');
      // Check if user document exists
      try {
        print('DEBUG: Fetching Firestore doc for ${user.uid}');
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        print('DEBUG: Doc fetch complete. Exists: ${doc.exists}');

        // Stop loading before navigation to avoid disposal issues
        isLoading.value = false;

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          print('DEBUG: Doc data: $data');

          // Save user to local storage via AuthService
          final userModel = UserModel.fromJson(data);
          await AuthService.to.saveUser(userModel);

          final role = userModel.role;
          print('DEBUG: User role: $role');

          if (role == 'attendee') {
            print('DEBUG: Navigating to ATTENDEE');
            Get.offAllNamed(Routes.ATTENDEE);
          } else {
            print('DEBUG: Navigating to SUPER_HOME');
            Get.offAllNamed(Routes.SUPER_HOME);
          }
        } else {
          print('DEBUG: Navigating to USER_DETAILS');
          Get.offAllNamed(Routes.USER_DETAILS);
        }
      } catch (e, stack) {
        print('DEBUG: Error in _onAuthSuccess: $e');
        print('DEBUG: Stack trace: $stack');
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to check user profile: $e');
      }
    } else {
      print('DEBUG: User is null in _onAuthSuccess');
      isLoading.value = false;
    }
  }
}
