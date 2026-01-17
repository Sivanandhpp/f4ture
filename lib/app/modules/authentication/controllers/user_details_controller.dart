import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/index.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class UserDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController(); // Read-only if passed
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<String> selectedInterests = <String>[].obs;

  // Password Visibility
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Focus Nodes
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  bool isGoogleAuth = false;

  final List<String> availableInterests = [
    'Concert',
    'Master Class',
    'Seminar',
    'Workshop',
    'Hackathon',
    'Exhibition',
    'Networking',
    'Panel',
    'Competition',
    'Festival',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    if (args.containsKey('email')) {
      emailController.text = args['email'] ?? '';
    }
    if (args.containsKey('name')) {
      nameController.text = args['name'] ?? '';
    }
    // Handle Google Auth case
    isGoogleAuth = args['isGoogle'] == true;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    phoneFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final result = await AppImagePicker.showImagePickerOptions();
    if (result != null) {
      selectedImage.value = result.selectedImage;
      selectedImageBytes.value = await result.selectedImage.readAsBytes();
    }
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        backgroundColor: AppColors.error,
      );
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        backgroundColor: AppColors.error,
      );
      return;
    }

    // Verify Password (Required for BOTH Google and Email)
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please set a password for your account',
        backgroundColor: AppColors.error,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: AppColors.error,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: AppColors.error,
      );
      return;
    }

    if (selectedImage.value == null && !isGoogleAuth) {
      // Require image for new email users? Or optional?
      // User asked to "ask for profile pic", usually helpful.
      Get.snackbar(
        'Error',
        'Please select a profile picture',
        backgroundColor: AppColors.error,
      );
      return;
    }

    isLoading.value = true;

    User? user;
    try {
      if (isGoogleAuth) {
        user = _auth.currentUser;
        // If password is set, update it
        if (user != null && passwordController.text.isNotEmpty) {
          try {
            await user.updatePassword(passwordController.text);
          } catch (e) {
            Get.snackbar(
              'Warning',
              'Failed to set password: $e',
              backgroundColor: Colors.orange,
            );
          }
        }
      } else {
        // Create user with Email/Password
        final cred = await AuthService.to.signUpWithEmail(
          email,
          passwordController.text,
        );
        user = cred.user;
      }

      if (user == null) {
        throw Exception('Failed to authenticate user');
      }

      // Upload Image if selected
      String? imageUrl;
      if (selectedImage.value != null) {
        final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
        final bytes = await selectedImage.value!.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        imageUrl = await ref.getDownloadURL();
      } else {
        // Use Google photo if available and no new image picked
        imageUrl = user.photoURL;
      }

      uploadedImageUrl.value = imageUrl ?? '';

      // Create User Document
      final newUser = UserModel(
        id: user.uid,
        name: name,
        phone: phone,
        email: email,
        role: 'attendee',
        status: 'active',
        profilePhoto: imageUrl,
        interests: selectedInterests.toList(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

      // Save user to local storage via AuthService
      await AuthService.to.saveUser(newUser);

      isLoading.value = false;
      Get.offAllNamed(Routes.NAVIGATION);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error);
    }
  }
}
