import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/group_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class GroupMember {
  final UserModel user;
  final String role; // 'admin', 'member'

  GroupMember({required this.user, required this.role});
}

class GroupDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late GroupModel group;
  final Rx<UserModel?> creator = Rx<UserModel?>(null);
  final RxList<GroupMember> members = <GroupMember>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isCurrentUserAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is GroupModel) {
      group = Get.arguments as GroupModel;
      _loadData();
    } else {
      Get.back();
    }
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([_fetchCreator(), _fetchMembers()]);
      _checkCurrentUserRole();
    } catch (e) {
      debugPrint('Error loading group details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCreator() async {
    if (group.createdBy.isEmpty) return;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(group.createdBy)
          .get();
      if (doc.exists) {
        creator.value = UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching creator: $e');
    }
  }

  Future<void> _fetchMembers() async {
    try {
      // 1. Get members from subcollection
      final snapshot = await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .get();

      if (snapshot.docs.isEmpty) return;

      final memberRoles = <String, String>{};
      final userIds = <String>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String? ?? 'member';
        final userId = doc.id; // Assuming doc ID is userId or stored in field
        // If doc ID is not userId, check logic. Usually it is.
        // Let's assume doc ID = userId.
        memberRoles[userId] = role;
        userIds.add(userId);
      }

      // 2. Fetch UserModels
      // splitting into chunks of 10 for 'whereIn' if list is huge,
      // but for now simple loop or single query if < 10
      // Actually often better to just fetch document by ID in parallel or loop if small.
      // 'whereIn' only supports 10. For a group, likely > 10.
      // Parallel fetches are cleaner for potentially 100+ users without limit logic complex.

      final memberList = <GroupMember>[];

      // Batch fetches logic could be complex. sticking to individual gets for simplicity
      // and consistency unless performance issue arises.
      // Optimization: Future.wait

      final futures = userIds.map(
        (id) => _firestore.collection('users').doc(id).get(),
      );
      final userDocs = await Future.wait(futures);

      for (var doc in userDocs) {
        if (doc.exists) {
          final user = UserModel.fromJson(doc.data()!);
          final role = memberRoles[user.id] ?? 'member';
          memberList.add(GroupMember(user: user, role: role));
        }
      }

      // 3. Sort
      memberList.sort((a, b) {
        // defined order: admin < member
        if (a.role == 'admin' && b.role != 'admin') return -1;
        if (a.role != 'admin' && b.role == 'admin') return 1;
        return a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase());
      });

      members.assignAll(memberList);
    } catch (e) {
      debugPrint('Error fetching members: $e');
    }
  }

  void _checkCurrentUserRole() {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final me = members.firstWhereOrNull((m) => m.user.id == uid);
      isCurrentUserAdmin.value = me?.role == 'admin';
    }
  }

  Future<void> addMembers(List<UserModel> newMembers) async {
    try {
      final batch = _firestore.batch();

      for (var member in newMembers) {
        // Double check not already member
        if (members.any((m) => m.user.id == member.id)) continue;

        final memberRef = _firestore
            .collection('groups')
            .doc(group.groupId)
            .collection('members')
            .doc(member.id);

        batch.set(memberRef, {
          'uid': member.id,
          'role': 'attendee', // Default role for added members
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Refresh list
      await _fetchMembers();
      Get.snackbar('Success', '${newMembers.length} members added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add members: $e');
    }
  }

  Future<void> makeAdmin(String userId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .doc(userId)
          .update({'role': 'admin'});

      // Refresh local list
      _updateLocalMemberRole(userId, 'admin');
      Get.snackbar('Success', 'User promoted to admin');
    } catch (e) {
      Get.snackbar('Error', 'Failed to promote user');
    }
  }

  Future<void> removeAdmin(String userId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .doc(userId)
          .update({'role': 'member'});

      _updateLocalMemberRole(userId, 'member');
      Get.snackbar('Success', 'User demoted to member');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role');
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .doc(userId)
          .delete();

      members.removeWhere((m) => m.user.id == userId);
      // Also decrease count?
      // Ideally trigger cloud function or update group doc count locally
      Get.snackbar('Success', 'User removed from group');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove user');
    }
  }

  Future<void> exitGroup() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .doc(uid)
          .delete();

      Get.offAllNamed('/home'); // Or appropriate route
    } catch (e) {
      Get.snackbar('Error', 'Failed to exit group');
    }
  }

  void _updateLocalMemberRole(String userId, String newRole) {
    final index = members.indexWhere((m) => m.user.id == userId);
    if (index != -1) {
      final old = members[index];
      members[index] = GroupMember(user: old.user, role: newRole);
      members.refresh();
      // Re-sort
      members.sort((a, b) {
        if (a.role == 'admin' && b.role != 'admin') return -1;
        if (a.role != 'admin' && b.role == 'admin') return 1;
        return a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase());
      });
    }
  }
}
