import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/issue_model.dart';
import 'package:f4ture/app/modules/chat/controllers/group_issues_controller.dart';
import 'package:f4ture/app/modules/chat/widgets/create_issue_sheet.dart';

class GroupIssuesView extends GetView<GroupIssuesController> {
  const GroupIssuesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: Obx(() {
        if (controller.issues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: 64,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'No issues reported',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openCreateSheet(),
                  icon: const Icon(Icons.add),
                  label: const Text('Report Issue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
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
          itemCount: controller.issues.length,
          itemBuilder: (context, index) {
            final issue = controller.issues[index];
            return _buildIssueCard(issue);
          },
        );
      }),
      floatingActionButton: Obx(
        () => controller.issues.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _openCreateSheet(),
                label: const Text('Report Issue'),
                icon: const Icon(Icons.warning_amber),
                backgroundColor: Colors.redAccent,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _openCreateSheet() {
    Get.bottomSheet(
      CreateIssueSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: AppColors.appbarbg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildIssueCard(IssueModel issue) {
    final isResolved = issue.status == IssueStatus.resolved;
    final color = _getSeverityColor(issue.severity);

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
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Open Details View
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(issue),
                    Text(
                      issue.severity.name.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isResolved ? TextDecoration.lineThrough : null,
                    color: isResolved ? Colors.grey : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  issue.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Reported ${DateFormat('MMM d').format(issue.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    if (issue.assignedTo.isNotEmpty)
                      const Icon(Icons.people, size: 16, color: Colors.grey)
                    else
                      Text(
                        'Unassigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
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

  Widget _buildStatusBadge(IssueModel issue) {
    Color bg;
    Color text;
    String label;

    switch (issue.status) {
      case IssueStatus.open:
        bg = Colors.red.withOpacity(0.2); // Increased opacity for dark mode
        text = Colors.red.shade300; // Lighter text
        label = 'Open';
        break;
      case IssueStatus.working:
        bg = Colors.blue.withOpacity(0.2);
        text = Colors.blue.shade300;
        label = 'Working';
        break;
      case IssueStatus.resolved:
        bg = Colors.green.withOpacity(0.2);
        text = Colors.green.shade300;
        label = 'Resolved';
        break;
    }

    return InkWell(
      onTap: () => _showStatusChangeOptions(issue),
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

  void _showStatusChangeOptions(IssueModel issue) {
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
            if (issue.status != IssueStatus.open)
              ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: const Text(
                  'Mark as Open',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  controller.updateStatus(issue.id, IssueStatus.open);
                },
              ),
            if (issue.status != IssueStatus.working)
              ListTile(
                leading: const Icon(Icons.sync, color: Colors.blue),
                title: const Text(
                  'Mark as Working',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  controller.updateStatus(issue.id, IssueStatus.working);
                },
              ),
            if (issue.status != IssueStatus.resolved)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text(
                  'Mark as Resolved',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  controller.updateStatus(issue.id, IssueStatus.resolved);
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.low:
        return Colors.green;
      case IssueSeverity.medium:
        return Colors.orange;
      case IssueSeverity.high:
        return Colors.deepOrange;
      case IssueSeverity.critical:
        return Colors.red.shade900;
    }
  }
}
