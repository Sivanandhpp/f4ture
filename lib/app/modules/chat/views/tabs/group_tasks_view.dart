import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/task_model.dart';
import 'package:f4ture/app/modules/chat/controllers/group_tasks_controller.dart';
import 'package:f4ture/app/modules/chat/widgets/create_task_sheet.dart'; // We will create this next

class GroupTasksView extends GetView<GroupTasksController> {
  const GroupTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized.
    // Ideally put this in parent binding, but for Tabs inside a View, local injection often safer if arguments needed.
    // For now, assuming it's injected.

    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: Obx(() {
        if (controller.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openCreateSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          itemCount: controller.tasks.length,
          itemBuilder: (context, index) {
            final task = controller.tasks[index];
            return _buildTaskCard(task);
          },
        );
      }),
      floatingActionButton: Obx(
        () => controller.tasks.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _openCreateSheet(context),
                label: const Text('New Task'),
                icon: const Icon(Icons.add),
                backgroundColor: AppColors.primary,
              )
            : const SizedBox.shrink(), // Hide FAB if empty view already shows button
      ),
    );
  }

  void _openCreateSheet(BuildContext context) {
    Get.bottomSheet(
      CreateTaskSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: AppColors.appbarbg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isDone = task.status == TaskStatus.completed;
    final color = _getPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.appbarbg, // Dark Card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Open Details View (Optional, expandable)
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(task),
                    Icon(Icons.flag, size: 16, color: color),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAssigneeAvatars(task.assignedTo),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d').format(task.dueAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.dueAt.isBefore(DateTime.now()) && !isDone
                            ? Colors.red
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TaskModel task) {
    Color bg;
    Color text;
    String label;

    switch (task.status) {
      case TaskStatus.pending:
        bg = Colors.orange.withOpacity(0.2);
        text = Colors.orange.shade300;
        label = 'Pending';
        break;
      case TaskStatus.inProgress:
        bg = Colors.blue.withOpacity(0.2);
        text = Colors.blue.shade300;
        label = 'In Progress';
        break;
      case TaskStatus.completed:
        bg = Colors.green.withOpacity(0.2);
        text = Colors.green.shade300;
        label = 'Completed';
        break;
    }

    return InkWell(
      onTap: () => _showStatusChangeOptions(task),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: text,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showStatusChangeOptions(TaskModel task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.appbarbg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (task.status != TaskStatus.pending)
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text(
                  'Mark as Pending',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  controller.updateStatus(task.id, TaskStatus.pending);
                },
              ),
            if (task.status != TaskStatus.inProgress)
              ListTile(
                leading: const Icon(Icons.sync, color: Colors.blue),
                title: const Text(
                  'Mark as In Progress',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  controller.updateStatus(task.id, TaskStatus.inProgress);
                },
              ),
            if (task.status != TaskStatus.completed)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text(
                  'Mark as Completed',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  controller.updateStatus(task.id, TaskStatus.completed);
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  Widget _buildAssigneeAvatars(List<String> userIds) {
    if (userIds.isEmpty) return const SizedBox.shrink();

    // We only have IDs here. The controller has the member list.
    // We need to resolve them.

    return Obx(() {
      final members = controller.groupMembers; // List<UserModel>
      final assignees = members.where((u) => userIds.contains(u.id)).toList();

      return Row(
        children: [
          for (var i = 0; i < assignees.length && i < 3; i++)
            Align(
              widthFactor: 0.7,
              child: CircleAvatar(
                radius: 12,
                backgroundImage: assignees[i].profilePhoto != null
                    ? NetworkImage(assignees[i].profilePhoto!)
                    : null,
                backgroundColor: Colors.grey.shade700,
                child: assignees[i].profilePhoto == null
                    ? Text(
                        assignees[i].name[0],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          if (assignees.length > 3)
            Align(
              widthFactor: 0.7,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade600,
                child: Text(
                  '+${assignees.length - 3}',
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                ),
              ),
            ),
        ],
      );
    });
  }
}
