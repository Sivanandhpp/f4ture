import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, inProgress, completed }

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String groupId;
  final List<String> assignedTo;
  final String createdBy;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.groupId,
    required this.assignedTo,
    required this.createdBy,
    required this.status,
    required this.priority,
    required this.dueAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'groupId': groupId,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'status': status.name,
      'priority': priority.name,
      'dueAt': Timestamp.fromDate(dueAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      groupId: json['groupId'] as String,
      assignedTo: List<String>.from(json['assignedTo'] ?? []),
      createdBy: json['createdBy'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueAt: (json['dueAt'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}
