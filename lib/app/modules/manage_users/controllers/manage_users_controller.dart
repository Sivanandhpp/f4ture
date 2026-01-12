import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/user_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageUsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchUsers();
  }

  void _fetchUsers() {
    isLoading.value = true;
    _firestore
        .collection('users')
        .orderBy('name')
        .snapshots()
        .listen(
          (snapshot) {
            allUsers.value = snapshot.docs
                .map((doc) => UserModel.fromJson(doc.data()))
                .toList();
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar(
              'Error',
              'Failed to fetch users: $e',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          },
        );
  }

  List<UserModel> get filteredUsers {
    // 1. Filter by Search
    var users = allUsers.where((user) {
      final query = searchQuery.value.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          (user.email?.toLowerCase().contains(query) ?? false) ||
          user.phone.contains(query);
    }).toList();

    // 2. Filter by Chip
    final filter = selectedFilter.value;
    if (filter == 'All') return users;

    if (filter == 'Jain') {
      return users.where((user) {
        return user.email?.toLowerCase().endsWith('@jainuniversity.ac.in') ??
            false;
      }).toList();
    }

    // Role Filters (Case insensitive match)
    return users
        .where((user) => user.role.toLowerCase() == filter.toLowerCase())
        .toList();
  }

  // --- Admin Actions ---

  Future<void> updateUserRole(String uid, String newRole) async {
    if (!_isAdmin) return;
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole.toLowerCase(),
      });
      Get.snackbar(
        'Success',
        'User role updated to $newRole',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update role',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleUserStatus(String uid, bool isActive) async {
    if (!_isAdmin) return;
    final status = isActive ? 'active' : 'inactive';
    try {
      await _firestore.collection('users').doc(uid).update({'status': status});
      // Optional: don't show snackbar for switches to avoid spam, or show succinct one
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  bool get _isAdmin {
    final currentUser = AuthService.to.currentUser.value;
    return currentUser?.role == 'admin';
  }
}
