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
  final emailController = TextEditingController();

  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<String> selectedInterests = <String>[].obs;

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
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final result = await AppImagePicker.showImagePickerOptions();
    if (result != null) {
      selectedImage.value = result.selectedImage;
      selectedImageBytes.value = await result.selectedImage.readAsBytes();
      // No need to manually dispose XFile, OS handles temp cache.
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
    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        backgroundColor: AppColors.error,
      );
      return;
    }

    if (selectedImage.value == null) {
      Get.snackbar(
        'Error',
        'Please select a profile picture',
        backgroundColor: AppColors.error,
      );
      return;
    }

    isLoading.value = true;
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      // 1. Upload Image
      final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');

      // Use bytes for cross-platform compatibility
      final bytes = await selectedImage.value!.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      final imageUrl = await ref.getDownloadURL();
      uploadedImageUrl.value = imageUrl;

      // 2. Create User Document
      final newUser = UserModel(
        id: user.uid,
        name: name,
        phone: user.phoneNumber ?? '',
        email: emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        role: 'attendee',
        status: 'active',
        profilePhoto: imageUrl,
        interests: selectedInterests.toList(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

      // Save user to local storage via AuthService
      await AuthService.to.saveUser(newUser);

      isLoading.value = false;
      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Success',
        'Profile setup complete!',
        backgroundColor: AppColors.success,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error);
    }
  }
}
