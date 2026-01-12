import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/issue_model.dart';
import 'package:f4ture/app/modules/chat/controllers/group_issues_controller.dart';

class CreateIssueSheet extends StatefulWidget {
  final GroupIssuesController controller;

  const CreateIssueSheet({super.key, required this.controller});

  @override
  State<CreateIssueSheet> createState() => _CreateIssueSheetState();
}

class _CreateIssueSheetState extends State<CreateIssueSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  IssueSeverity _severity = IssueSeverity.medium;

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required');
      return;
    }

    widget.controller.createIssue(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      severity: _severity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Issue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
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
                    decoration: InputDecoration(
                      labelText: 'Issue Title',
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
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Severity
                  const Text(
                    'Severity',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: IssueSeverity.values.map((s) {
                      final isSelected = _severity == s;
                      Color color;
                      switch (s) {
                        case IssueSeverity.low:
                          color = Colors.green;
                          break;
                        case IssueSeverity.medium:
                          color = Colors.orange;
                          break;
                        case IssueSeverity.high:
                          color = Colors.deepOrange;
                          break;
                        case IssueSeverity.critical:
                          color = Colors.red;
                          break;
                      }

                      return ChoiceChip(
                        label: Text(s.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _severity = s),
                        selectedColor: color.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? color : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Report',
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
