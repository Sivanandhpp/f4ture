import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/group_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class GroupTasksController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GroupModel group;
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxList<UserModel> groupMembers = <UserModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Assuming ChatController or arguments pass the group
    // We can find the group via arguments or by finding ChatController
    if (Get.arguments is GroupModel) {
      group = Get.arguments as GroupModel;
    } else {
      // Fallback: try to find from ChatController if active
      // For now, assume arguments passed correctly or handled by binding
    }
    _bindTasks();
    _fetchMembers();
  }

  // Bind to the lightweight tasks collection in the group
  void _bindTasks() {
    // Note: The lightweight ref might not have all details if cloud function is slow?
    // Actually, Cloud Function copies essential fields.
    // If we need FULL details, we might query the root `tasks` collection where groupId == group.id.
    // Querying root `tasks` is safer for real-time consistency if Functions lag.
    // Let's query root `tasks` with groupId filter for the main list.

    // HOWEVER, the plan mentioned referencing groups/{id}/tasks.
    // Let's stick to the "Source of Truth" pattern:
    // Query root `tasks` where `groupId` == group.id.
    // References are mostly for reading simple lists without strict index requirements or for local caching.
    // Given we want "production ready", querying root with index is standard.

    tasks.bindStream(
      _firestore
          .collection('tasks')
          .where('groupId', isEqualTo: group.groupId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => TaskModel.fromJson(doc.data()))
                .toList(),
          ),
    );
  }

  Future<void> _fetchMembers() async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .get();

      final userIds = snapshot.docs.map((d) => d.id).toList();
      if (userIds.isEmpty) return;

      // In production, use chunking for > 10 IDs.
      final futures = userIds.map(
        (id) => _firestore.collection('users').doc(id).get(),
      );
      final docs = await Future.wait(futures);

      groupMembers.assignAll(
        docs.where((d) => d.exists).map((d) => UserModel.fromJson(d.data()!)),
      );
    } catch (e) {
      debugPrint('Error fetching members: $e');
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    required List<String> assignedTo, // IDs
    required TaskPriority priority,
    required DateTime dueAt,
  }) async {
    try {
      final id = _firestore.collection('tasks').doc().id;
      final uid = AuthService.to.currentUser.value!.id;

      final newTask = TaskModel(
        id: id,
        title: title,
        description: description,
        groupId: group.groupId,
        assignedTo: assignedTo,
        createdBy: uid,
        status: TaskStatus.pending,
        priority: priority,
        dueAt: dueAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('tasks').doc(id).set(newTask.toJson());

      Get.back(); // Close sheet
      Get.snackbar('Success', 'Task created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create task: $e');
    }
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }
}
