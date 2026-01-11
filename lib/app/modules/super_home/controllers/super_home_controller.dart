import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/index.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/auth_service.dart';

class SuperHomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final groupNameController = TextEditingController();
  final groupDescriptionController = TextEditingController();

  final Rx<XFile?> selectedGroupIcon = Rx<XFile?>(null);
  final Rx<Uint8List?> selectedGroupIconBytes = Rx<Uint8List?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'public'.obs; // public, private, committee

  final RxInt tabIndex = 1.obs; // Default to Chats tab (Index 1)

  // Stream of groups
  Stream<List<GroupModel>> get groupsStream {
    final user = AuthService.to.currentUser.value;
    if (user == null) return Stream.value([]);

    // 1. Admin: Return all groups
    if (user.role == 'admin') {
      return _firestore
          .collection('groups')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => GroupModel.fromJson(doc.data()))
                .toList(),
          );
    }

    // 2. Regular User: Return only joined groups
    return _firestore
        .collection('users')
        .doc(user.id)
        .collection('groups')
        .snapshots()
        .asyncMap((snapshot) async {
          final groupIds = snapshot.docs.map((doc) => doc.id).toList();

          if (groupIds.isEmpty) return <GroupModel>[];

          // Fetch details for each group
          final groupDocs = await Future.wait(
            groupIds.map((id) => _firestore.collection('groups').doc(id).get()),
          );

          return groupDocs
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => GroupModel.fromJson(doc.data()!))
              .toList()
            // Sort manually since we fetched individually
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
  }

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
      selectedGroupIconBytes.value = await result.selectedImage.readAsBytes();
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

      // Use bytes for cross-platform compatibility
      final bytes = await selectedGroupIcon.value!.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

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

  void changeTab(int index) {
    tabIndex.value = index;
  }
}
