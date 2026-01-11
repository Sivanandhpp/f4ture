import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../../../data/models/group_model.dart';

class SuperHomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final groupNameController = TextEditingController();
  final groupDescriptionController = TextEditingController();

  final Rx<File?> selectedGroupIcon = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'public'.obs; // public, private, committee

  // Stream of groups
  Stream<List<GroupModel>> get groupsStream => _firestore
      .collection('groups')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromJson(doc.data()))
            .toList(),
      );

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.onClose();
  }

  Future<void> pickGroupIcon() async {
    final result = await AppImagePicker.showImagePickerOptions();
    if (result != null) {
      selectedGroupIcon.value = result.selectedImage;
    }
  }

  Future<void> createGroup() async {
    if (groupNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a group name',
        backgroundColor: AppColors.error,
      );
      return;
    }
    if (selectedGroupIcon.value == null) {
      Get.snackbar(
        'Error',
        'Please select a group icon',
        backgroundColor: AppColors.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final groupId = _firestore.collection('groups').doc().id;
      final ref = _storage.ref().child('group_icons/$groupId.jpg');
      await ref.putFile(selectedGroupIcon.value!);
      final iconUrl = await ref.getDownloadURL();

      final newGroup = GroupModel(
        groupId: groupId,
        name: groupNameController.text.trim(),
        iconUrl: iconUrl,
        description: groupDescriptionController.text.trim(),
        createdBy: user.uid,
        createdAt: DateTime.now(),
        lastMessage: 'Group created',
        lastMessageAt: DateTime.now(),
        membersCount: 1, // Creator
        type: selectedType.value,
      );

      await _firestore.collection('groups').doc(groupId).set(newGroup.toJson());

      // Add creator to members subcollection
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'role': 'admin',
            'joinedAt': FieldValue.serverTimestamp(),
          });

      isLoading.value = false;
      Get.back(); // Close CreateGroupView
      Get.snackbar(
        'Success',
        'Group created successfully',
        backgroundColor: AppColors.success,
      );

      // Cleanup
      groupNameController.clear();
      groupDescriptionController.clear();
      selectedGroupIcon.value = null;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to create group: $e',
        backgroundColor: AppColors.error,
      );
    }
  }
}
