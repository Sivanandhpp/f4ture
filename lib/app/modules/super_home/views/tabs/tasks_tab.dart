import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:f4ture/app/core/index.dart';
import 'package:f4ture/app/data/models/task_model.dart';
import 'package:f4ture/app/data/models/issue_model.dart';
import 'package:f4ture/app/modules/super_home/controllers/global_tasks_controller.dart';

class TasksTab extends GetView<GlobalTasksController> {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GlobalTasksController()); // Ensure controller is initialized

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Work',
          style: AppFont.heading.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [_buildSortButton(), const SizedBox(width: 8)],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildUnifiedList()),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort, color: AppColors.primary),
      onSelected: controller.changeSort,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Priority',
          child: Text('Priority (High to Low)'),
        ),
        const PopupMenuItem(value: 'Newest', child: Text('Newest First')),
        const PopupMenuItem(
          value: 'Due Date',
          child: Text('Due Date (Sooner First)'),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('All'),
          const SizedBox(width: 8),
          _buildChip('Tasks'),
          const SizedBox(width: 8),
          _buildChip('Issues'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.changeFilter(label),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        checkmarkColor: AppColors.primary,
      );
    });
  }

  Widget _buildUnifiedList() {
    return Obx(() {
      if (controller.isLoadingTasks.value || controller.isLoadingIssues.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.mixedList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No items found',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.mixedList.length,
        itemBuilder: (context, index) {
          final item = controller.mixedList[index];
          if (item is TaskModel) {
            return _buildTaskCard(item);
          } else if (item is IssueModel) {
            return _buildIssueCard(item);
          }
          return const SizedBox.shrink();
        },
      );
    });
  }

  Widget _buildTaskCard(TaskModel task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'TASK',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildTaskStatusBadge(task.status, task.id),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriorityBadge(task.priority),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d').format(task.dueAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCard(IssueModel issue) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'ISSUE',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildIssueStatusBadge(issue.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (issue.description.isNotEmpty) ...[
              Text(
                issue.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeverityBadge(issue.severity),
                Text(
                  'Reported: ${DateFormat('MMM d').format(issue.createdAt)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusBadge(TaskStatus status, String taskId) {
    Color color;
    String text;

    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case TaskStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
    }

    return PopupMenuButton<TaskStatus>(
      initialValue: status,
      onSelected: (newStatus) {
        if (newStatus != status) {
          controller.updateTaskStatus(taskId, newStatus);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: color),
          ],
        ),
      ),
      itemBuilder: (context) => TaskStatus.values.map((s) {
        return PopupMenuItem(
          value: s,
          child: Text(s.name.replaceAll('_', ' ').capitalizeFirst!),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        text = 'Low';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case TaskPriority.high:
        color = Colors.red;
        text = 'High';
        break;
    }

    return Row(
      children: [
        Icon(Icons.flag, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIssueStatusBadge(IssueStatus status) {
    Color color;
    String text;

    switch (status) {
      case IssueStatus.open:
        color = Colors.red;
        text = 'Open';
        break;
      case IssueStatus.working:
        color = Colors.orange;
        text = 'Working';
        break;
      case IssueStatus.resolved:
        color = Colors.green;
        text = 'Resolved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(IssueSeverity severity) {
    Color color;
    String text;

    switch (severity) {
      case IssueSeverity.low:
        color = Colors.green;
        text = 'Low';
        break;
      case IssueSeverity.medium:
        color = Colors.blue;
        text = 'Medium';
        break;
      case IssueSeverity.high:
        color = Colors.orange;
        text = 'High';
        break;
      case IssueSeverity.critical:
        color = Colors.red;
        text = 'Critical';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
