import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:f4ture/app/data/models/issue_model.dart';
import 'package:f4ture/app/data/models/task_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/modules/super_home/controllers/global_tasks_controller.dart';

import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../super_home/views/create_group_view.dart';
import '../controllers/admin_console_controller.dart';

class AdminConsoleView extends GetView<AdminConsoleController> {
  const AdminConsoleView({super.key});

  @override
  Widget build(BuildContext context) {
    // Access GlobalTasksController for My Work section
    final tasksController = Get.find<GlobalTasksController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      appBar: AppBar(
        title: Text(
          'Admin Console',
          style: AppFont.heading.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appbarbg,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),

            // 2. Admin Control Section
            _buildSectionHeader('Admin Controls'),
            const SizedBox(height: 12),
            _buildAdminControls(context),
            const SizedBox(height: 24),

            // 3. My Work Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('My Work'),
                _buildSortButton(tasksController),
              ],
            ),
            const SizedBox(height: 12),
            _buildFilterChips(tasksController),
            const SizedBox(height: 12),
            _buildUnifiedList(tasksController),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // --- Profile Section ---
  Widget _buildProfileSection() {
    return Obx(() {
      final user = AuthService.to.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.appbarbg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Pic
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: user.profilePhoto != null
                    ? NetworkImage(user.profilePhoto!)
                    : null,
                backgroundColor: Colors.grey.shade900,
                child: user.profilePhoto == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purpleAccent),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.purple.withOpacity(0.1),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (user.phone.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.phone,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  if (user.email != null)
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.email!,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- Admin Controls ---
  Widget _buildAdminControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAdminCard(
            title: 'Events',
            subtitle: 'Manage',
            icon: Icons.event_note,
            color: Colors.purple,
            onTap: () => Get.toNamed(Routes.MANAGE_EVENTS),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAdminCard(
            title: 'Groups',
            subtitle: 'Create',
            icon: Icons.group_add,
            color: Colors.blue,
            onTap: () => Get.to(() => const CreateGroupView()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAdminCard(
            title: 'Users',
            subtitle: 'Manage',
            icon: Icons.manage_accounts,
            color: Colors.grey,
            onTap: () => Get.toNamed(Routes.MANAGE_USERS),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.appbarbg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // --- My Work Section ---
  Widget _buildFilterChips(GlobalTasksController controller) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['All', 'Tasks', 'Issues', 'Completed'].map((filter) {
          return _buildChip(controller, filter);
        }).toList(),
      ),
    );
  }

  Widget _buildChip(GlobalTasksController controller, String label) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == label;
      return GestureDetector(
        onTap: () => controller.changeFilter(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUnifiedList(GlobalTasksController controller) {
    return Obx(() {
      if ((controller.isLoadingTasks.value ||
              controller.isLoadingIssues.value) &&
          controller.mixedList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.mixedList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 12),
              Text(
                'No items found',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.mixedList.length,
        itemBuilder: (context, index) {
          final item = controller.mixedList[index];
          if (item is TaskModel) {
            return _buildTaskCard(controller, item);
          } else if (item is IssueModel) {
            return _buildIssueCard(controller, item);
          }
          return const SizedBox.shrink();
        },
      );
    });
  }

  // --- Task/Issue Helpers (Reused from TasksTab Logic) ---

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    final time = DateFormat('hh:mm a').format(date);

    if (checkDate == today) {
      return 'Today $time';
    } else if (checkDate == yesterday) {
      return 'Yesterday $time';
    } else {
      return '${DateFormat('MMM d').format(date)} $time';
    }
  }

  Widget _buildTaskCard(GlobalTasksController controller, TaskModel task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.appbarbg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, size: 14, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'TASK',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildTaskStatusBadge(controller, task.status, task.id),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPriorityBadge(task.priority),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: task.dueAt.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.dueAt),
                      style: TextStyle(
                        color: task.dueAt.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildIssueCard(GlobalTasksController controller, IssueModel issue) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.appbarbg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, size: 14, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'ISSUE',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildIssueStatusBadge(controller, issue),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (issue.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                issue.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeverityBadge(issue.severity),
                Text(
                  'On ${_formatDateTime(issue.createdAt)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusBadge(
    GlobalTasksController controller,
    TaskStatus status,
    String taskId,
  ) {
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
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 14, color: color),
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

  Widget _buildIssueStatusBadge(
    GlobalTasksController controller,
    IssueModel issue,
  ) {
    final status = issue.status;
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

    return PopupMenuButton<IssueStatus>(
      initialValue: status,
      onSelected: (newStatus) {
        if (newStatus != status) {
          controller.updateIssueStatus(issue.id, newStatus);
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
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 14, color: color),
          ],
        ),
      ),
      itemBuilder: (context) => IssueStatus.values.map((s) {
        return PopupMenuItem(value: s, child: Text(s.name.capitalizeFirst!));
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSortButton(GlobalTasksController controller) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort, color: AppColors.primary),
      onSelected: controller.changeSort,
      color: AppColors.appbarbg, // Dark menu
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Priority',
          child: Text(
            'Priority (High to Low)',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const PopupMenuItem(
          value: 'Newest',
          child: Text('Newest First', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem(
          value: 'Due Date',
          child: Text(
            'Due Date (Sooner First)',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
