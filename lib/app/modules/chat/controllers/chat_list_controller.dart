import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_image_picker.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_chat_service.dart';
import '../../../routes/app_pages.dart';

class ChatListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final groupNameController = TextEditingController();
  final groupDescriptionController = TextEditingController();

  final Rx<XFile?> selectedGroupIcon = Rx<XFile?>(null);
  final Rx<Uint8List?> selectedGroupIconBytes = Rx<Uint8List?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'public'.obs; // public, private, committee

  final RxList<UserModel> selectedMembers = <UserModel>[].obs;

  final RxList<String> myGroupIds = <String>[].obs;
  final RxList<GroupModel> publicGroups = <GroupModel>[].obs;
  final RxBool isPublicGroupsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _bindMyGroups();
    _bindPublicGroups();
  }

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.onClose();
  }

  void updateSelectedMembers(List<UserModel> members) {
    selectedMembers.value = members;
  }

  void removeMember(UserModel member) {
    selectedMembers.remove(member);
  }

  // Stream of groups
  Stream<List<GroupModel>> get groupsStream {
    final user = AuthService.to.currentUser.value;
    if (user == null) return Stream.value([]);

    // 1. Admin: Return all groups
    if (user.role == 'admin') {
      return _firestore
          .collection('groups')
          .orderBy('lastMessageAt', descending: true)
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
          if (snapshot.docs.isEmpty) return <GroupModel>[];

          // Map groupId to joinedAt to use as fallback for lastRead
          final groupJoinDates = {
            for (var doc in snapshot.docs)
              doc.id:
                  (doc.data()['joinedAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
          };

          final groupIds = snapshot.docs.map((doc) => doc.id).toList();

          final groupsWithCounts = await Future.wait(
            groupIds.map((id) async {
              final groupDoc = await _firestore
                  .collection('groups')
                  .doc(id)
                  .get();
              if (!groupDoc.exists) return null;

              final group = GroupModel.fromJson(groupDoc.data()!);

              // Local Unread Logic
              final lastRead =
                  LocalChatService.to.getLastRead(id) ?? groupJoinDates[id]!;
              int unread = 0;

              // Only query if there might be unread messages
              if (group.lastMessageAt.isAfter(lastRead)) {
                try {
                  final countQuery = await _firestore
                      .collection('groups')
                      .doc(id)
                      .collection('messages')
                      .where(
                        'createdAt',
                        isGreaterThan: Timestamp.fromDate(lastRead),
                      )
                      .count()
                      .get();
                  unread = countQuery.count ?? 0;
                } catch (e) {
                  debugPrint('Error counting unread for $id: $e');
                }
              }

              return group.copyWith(unreadCount: unread);
            }),
          );

          return groupsWithCounts
              .where((g) => g != null)
              .cast<GroupModel>()
              .toList()
            // Sort manually by lastMessageAt descending
            ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
        });
  }

  void _bindMyGroups() {
    final user = AuthService.to.currentUser.value;
    if (user != null) {
      myGroupIds.bindStream(
        _firestore
            .collection('users')
            .doc(user.id)
            .collection('groups')
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList()),
      );
    }
  }

  void _bindPublicGroups() {
    publicGroups.bindStream(
      _firestore
          .collection('groups')
          .where('type', isEqualTo: 'public')
          .snapshots()
          .map((snapshot) {
            // Side effect: stop loading when data arrives
            isPublicGroupsLoading.value = false;
            return snapshot.docs
                .map((doc) => GroupModel.fromJson(doc.data()))
                .toList();
          })
          .handleError((error) {
            debugPrint('Error fetching public groups: $error');
            isPublicGroupsLoading.value = false;
            return []; // Return empty list on error
          }),
    );
  }

  Future<void> joinGroup(GroupModel group) async {
    try {
      final user = AuthService.to.currentUser.value;
      if (user == null) return;

      final batch = _firestore.batch();

      // 1. Add user to group's members subcollection
      final memberRef = _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .doc(user.id);

      batch.set(memberRef, {
        'uid': user.id,
        'role': 'attendee',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add group to user's groups subcollection
      final userGroupRef = _firestore
          .collection('users')
          .doc(user.id)
          .collection('groups')
          .doc(group.groupId);

      batch.set(userGroupRef, {
        'groupId': group.groupId,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      Get.snackbar(
        'Welcome',
        'You have joined ${group.name}',
        backgroundColor: AppColors.success,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Open the chat immediately
      Get.toNamed(Routes.CHAT, arguments: group);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to join group: $e',
        backgroundColor: AppColors.error,
      );
    }
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

    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one member',
        backgroundColor: AppColors.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final groupId = _firestore.collection('groups').doc().id;
      final iconsRef = _storage.ref().child('group_icons/$groupId.jpg');

      // Use bytes for cross-platform compatibility
      final bytes = await selectedGroupIcon.value!.readAsBytes();
      await iconsRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final iconUrl = await iconsRef.getDownloadURL();

      final newGroup = GroupModel(
        groupId: groupId,
        name: groupNameController.text.trim(),
        iconUrl: iconUrl,
        description: groupDescriptionController.text.trim(),
        createdBy: user.uid,
        createdAt: DateTime.now(),
        lastMessage: 'Group created',
        lastMessageAt: DateTime.now(),
        membersCount: 0, // let Cloud Function increment it (syncGroupToUser)
        type: selectedType.value,
      );

      final batch = _firestore.batch();

      // 1. Create Group Doc
      batch.set(
        _firestore.collection('groups').doc(groupId),
        newGroup.toJson(),
      );

      // 2. Add Creator to Members
      final creatorRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(user.uid);

      batch.set(creatorRef, {
        'uid': user.uid,
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 3. Add Selected Members
      for (var member in selectedMembers) {
        final memberRef = _firestore
            .collection('groups')
            .doc(groupId)
            .collection('members')
            .doc(member.id);

        batch.set(memberRef, {
          'uid': member.id,
          'role': 'attendee', // Default role
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

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
      selectedGroupIconBytes.value = null;
      selectedMembers.clear();
      selectedType.value = 'public';
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
