import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/data/models/task_model.dart';
import 'package:f4ture/app/data/models/issue_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';

class GlobalTasksController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxString selectedFilter = 'All'.obs; // All, Tasks, Issues
  final RxString selectedSort = 'Priority'.obs; // Priority, Due Date, Newest

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
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoadingTasks.value = true;
      // Query root tasks collection directly to avoid dependency on undeployed Cloud Functions
      final snapshot = await _db
          .collection('tasks')
          .where('assignedTo', arrayContains: userId)
          .get();

      myTasks.value = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
      _updateMixedList();
    } catch (e) {
      print('Error fetching my tasks: $e');
    } finally {
      isLoadingTasks.value = false;
    }
  }

  Future<void> fetchMyIssues() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoadingIssues.value = true;
      // Query root issues collection directly
      final snapshot = await _db
          .collection('issues')
          .where('assignedTo', arrayContains: userId)
          .get();

      // Also could show issues REPORTED by user? The prompt says "assigned".
      // Sticking to assignedTo for "My Work".

      myIssues.value = snapshot.docs
          .map((doc) => IssueModel.fromJson(doc.data()))
          .toList();
      _updateMixedList();
    } catch (e) {
      print('Error fetching my issues: $e');
    } finally {
      isLoadingIssues.value = false;
    }
  }

  void _updateMixedList() {
    List<dynamic> all = [];

    // Filter
    if (selectedFilter.value == 'All' || selectedFilter.value == 'Tasks') {
      all.addAll(myTasks);
    }
    if (selectedFilter.value == 'All' || selectedFilter.value == 'Issues') {
      all.addAll(myIssues);
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
        // Map severity to roughly equivalent priority?
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
}
