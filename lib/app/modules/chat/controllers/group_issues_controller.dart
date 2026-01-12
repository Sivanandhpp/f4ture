import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/group_model.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

class GroupIssuesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GroupModel group;
  final RxList<IssueModel> issues = <IssueModel>[].obs;
  final RxList<UserModel> groupMembers = <UserModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Assuming context is similar to TaskController
    if (Get.arguments is GroupModel) {
      group = Get.arguments as GroupModel;
    }
    _bindIssues();
  }

  void _bindIssues() {
    issues.bindStream(
      _firestore
          .collection('issues')
          .where('groupId', isEqualTo: group.groupId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => IssueModel.fromJson(doc.data()))
                .toList(),
          ),
    );
  }

  Future<void> createIssue({
    required String title,
    required String description,
    required IssueSeverity severity,
  }) async {
    try {
      final id = _firestore.collection('issues').doc().id;
      final uid = AuthService.to.currentUser.value!.id;

      // Fetch admins to assign
      final membersSnapshot = await _firestore
          .collection('groups')
          .doc(group.groupId)
          .collection('members')
          .where('role', whereIn: ['admin', 'owner'])
          .get();

      final adminIds = membersSnapshot.docs.map((doc) => doc.id).toList();

      // Ensure at least one assignee if possible, else leave empty (or assign to creator?)
      // User requested "always assign to respective group admins"

      final newIssue = IssueModel(
        id: id,
        title: title,
        description: description,
        groupId: group.groupId,
        assignedTo: adminIds,
        reportedBy: uid,
        status: IssueStatus.open,
        severity: severity,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('issues').doc(id).set(newIssue.toJson());
      Get.back();
      Get.snackbar('Success', 'Issue reported successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to report issue');
    }
  }

  Future<void> updateStatus(String issueId, IssueStatus status) async {
    try {
      await _firestore.collection('issues').doc(issueId).update({
        'status': status.name,
        'resolvedAt': status == IssueStatus.resolved
            ? FieldValue.serverTimestamp()
            : null,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }
}
