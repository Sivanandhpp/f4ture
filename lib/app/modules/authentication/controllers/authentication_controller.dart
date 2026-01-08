import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController {
  // Text controllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // State
  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final phoneNumber = ''.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Send OTP to phone number
  Future<void> sendOtp() async {
    if (phoneController.text.length < 10) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    phoneNumber.value = phoneController.text;
    isOtpSent.value = true;
    isLoading.value = false;

    Get.snackbar('Success', 'OTP sent to ${phoneNumber.value}');
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;

    // TODO: Navigate to home or next screen
    Get.snackbar('Success', 'OTP verified successfully!');
  }

  /// Edit phone number (go back to phone input)
  void editPhoneNumber() {
    isOtpSent.value = false;
    otpController.clear();
  }
}
