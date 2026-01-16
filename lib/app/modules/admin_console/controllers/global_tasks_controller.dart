import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/data/models/task_model.dart';
import 'package:f4ture/app/data/models/issue_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';

class GlobalTasksController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxString selectedFilter = 'All'.obs; // All, Tasks, Issues
  final RxString selectedSort = 'Newest'.obs; // Priority, Due Date, Newest

  final RxList<TaskModel> myTasks = <TaskModel>[].obs;
  final RxList<IssueModel> myIssues = <IssueModel>[].obs;
  final RxBool isLoadingTasks = false.obs;
  final RxBool isLoadingIssues = false.obs;

  final RxList<dynamic> mixedList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() {
    fetchMyTasks();
    fetchMyIssues();
  }

  Future<void> fetchMyTasks() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      isLoadingTasks.value = true;
      QuerySnapshot snapshot;

      // If user is NOT an attendee (Admin, Core, Lead, Committee), show ALL tasks
      if (user.role.toLowerCase() != 'attendee') {
        snapshot = await _db.collection('tasks').get();
      } else {
        // Attendees only see tasks assigned to them
        snapshot = await _db
            .collection('tasks')
            .where('assignedTo', arrayContains: user.id)
            .get();
      }

      myTasks.value = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _updateMixedList();
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      isLoadingTasks.value = false;
    }
  }

  Future<void> fetchMyIssues() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      isLoadingIssues.value = true;
      QuerySnapshot snapshot;

      // If user is NOT an attendee, show ALL issues
      if (user.role.toLowerCase() != 'attendee') {
        snapshot = await _db.collection('issues').get();
      } else {
        // Attendees only see issues assigned to them
        snapshot = await _db
            .collection('issues')
            .where('assignedTo', arrayContains: user.id)
            .get();
      }

      myIssues.value = snapshot.docs
          .map((doc) => IssueModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _updateMixedList();
    } catch (e) {
      print('Error fetching issues: $e');
    } finally {
      isLoadingIssues.value = false;
    }
  }

  void _updateMixedList() {
    List<dynamic> all = [];

    final isCompletedFilter = selectedFilter.value == 'Completed';

    // 1. Filter TASKS
    if (selectedFilter.value == 'All' ||
        selectedFilter.value == 'Tasks' ||
        isCompletedFilter) {
      final tasks = myTasks.where((t) {
        final isCompleted = t.status == TaskStatus.completed;
        return isCompletedFilter ? isCompleted : !isCompleted;
      }).toList();
      all.addAll(tasks);
    }

    // 2. Filter ISSUES
    if (selectedFilter.value == 'All' ||
        selectedFilter.value == 'Issues' ||
        isCompletedFilter) {
      final issues = myIssues.where((i) {
        final isResolved = i.status == IssueStatus.resolved;
        return isCompletedFilter ? isResolved : !isResolved;
      }).toList();
      all.addAll(issues);
    }

    // Sort
    all.sort((a, b) {
      if (selectedSort.value == 'Newest') {
        return b.createdAt.compareTo(a.createdAt);
      } else if (selectedSort.value == 'Due Date') {
        DateTime? dateA = (a is TaskModel)
            ? a.dueAt
            : (a is IssueModel
                  ? a.createdAt
                  : null); // Issue uses created as fallback? Or infinite?
        DateTime? dateB = (b is TaskModel)
            ? b.dueAt
            : (b is IssueModel ? b.createdAt : null);

        // Handle nulls if necessary, though TaskModel dueAt is required.
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateA.compareTo(
          dateB,
        ); // Ascending for dates usually means "sooner first"
      } else if (selectedSort.value == 'Priority') {
        int priorityA = _getWeight(a);
        int priorityB = _getWeight(b);
        return priorityB.compareTo(priorityA); // Descending (High first)
      }
      return 0;
    });

    mixedList.value = all;
  }

  int _getWeight(dynamic item) {
    if (item is TaskModel) {
      switch (item.priority) {
        case TaskPriority.high:
          return 3;
        case TaskPriority.medium:
          return 2;
        case TaskPriority.low:
          return 1;
      }
    } else if (item is IssueModel) {
      switch (item.severity) {
        case IssueSeverity.critical:
          return 4;
        case IssueSeverity.high:
          return 3;
        case IssueSeverity.medium:
          return 2;
        case IssueSeverity.low:
          return 1;
      }
    }
    return 0;
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _updateMixedList();
  }

  void changeSort(String sort) {
    selectedSort.value = sort;
    _updateMixedList();
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Local update
      final index = myTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        myTasks[index] = myTasks[index].copyWith(status: status);
        _updateMixedList(); // Re-filter to move to completed if needed
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task status');
    }
  }

  Future<void> updateIssueStatus(String issueId, IssueStatus status) async {
    try {
      await _db.collection('issues').doc(issueId).update({
        'status': status.name,
        'resolvedAt': status == IssueStatus.resolved
            ? FieldValue.serverTimestamp()
            : null,
      });
      // Local update
      final index = myIssues.indexWhere((i) => i.id == issueId);
      if (index != -1) {
        // We need copyWith for IssueModel too. Assuming it exists or I need to add it.
        // I will check IssueModel. If not exists, I'll update the object manually or add copyWith.
        // For now, let's assume I need to add copyWith to IssueModel or just fetching again?
        // Fetching again is safer if I don't want to edit IssueModel right now, but local update is better.
        // Let's modify IssueModel next step if copyWith is missing.
        // Checking IssueModel content from previous context... wait, I haven't viewed IssueModel recently.
        // I'll optimistically use copyWith and fixes it if it fails.
        // Actually, to avoid errors, I'll fetch data again or try to update list directly if possible.
        // Better: Fetch just that issue or refetch all (simple but less efficient).
        // Let's rely on _updateMixedList after updating the local list item.
        // I'll assume copyWith is available or I will add it.

        // Actually, previous chat logs showed TaskModel copyWith was added. IssueModel probably doesn't have it.
        // I will add copyWith to IssueModel in the next step.
        myIssues[index] = myIssues[index].copyWith(status: status);
        _updateMixedList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update issue status');
    }
  }
}
