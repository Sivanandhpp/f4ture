import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/task_model.dart';
import 'package:f4ture/app/modules/chat/controllers/group_tasks_controller.dart';

class CreateTaskSheet extends StatefulWidget {
  final GroupTasksController controller;

  const CreateTaskSheet({super.key, required this.controller});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime _dueAt = DateTime.now().add(const Duration(days: 1));
  final List<String> _selectedAssignees = [];
  bool _assignToEveryone = false;

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required');
      return;
    }
    if (_selectedAssignees.isEmpty && !_assignToEveryone) {
      Get.snackbar('Error', 'Select at least one assignee');
      return;
    }

    final assignees = _assignToEveryone
        ? widget.controller.groupMembers.map((u) => u.id).toList()
        : _selectedAssignees;

    widget.controller.createTask(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      assignedTo: assignees,
      priority: _priority,
      dueAt: _dueAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.appbarbg, // Dark background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Task',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority
                  const Text(
                    'Priority',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: TaskPriority.values.map((p) {
                      final isSelected = _priority == p;
                      return ChoiceChip(
                        label: Text(p.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _priority = p),
                        backgroundColor: AppColors.scaffoldbg,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[800]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Due Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    trailing: TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          currentDate: _dueAt,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: AppColors.appbarbg,
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: AppColors.appbarbg,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          if (!context.mounted) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_dueAt),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    surface: AppColors.appbarbg,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setState(() {
                              _dueAt = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          } else {
                            setState(() {
                              _dueAt = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _dueAt.hour,
                                _dueAt.minute,
                              );
                            });
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        DateFormat('MMM d, yyyy h:mm a').format(_dueAt),
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey),

                  // Assignees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assign To',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _assignToEveryone = !_assignToEveryone;
                            if (_assignToEveryone) _selectedAssignees.clear();
                          });
                        },
                        child: Text(
                          _assignToEveryone
                              ? 'Custom Select'
                              : 'Assign Everyone',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  if (!_assignToEveryone)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(top: 8),
                      child: Obx(
                        () => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.controller.groupMembers.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final user = widget.controller.groupMembers[index];
                            final isSelected = _selectedAssignees.contains(
                              user.id,
                            );

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedAssignees.remove(user.id);
                                  } else {
                                    _selectedAssignees.add(user.id);
                                  }
                                });
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: user.profilePhoto != null
                                        ? NetworkImage(user.profilePhoto!)
                                        : null,
                                    backgroundColor: Colors.grey[800],
                                    child: user.profilePhoto == null
                                        ? Text(
                                            user.name[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.groups, color: Colors.green),
                          SizedBox(width: 12),
                          Text(
                            'Task will be assigned to all group members',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create Task',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
