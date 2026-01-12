import 'package:cloud_firestore/cloud_firestore.dart';

enum IssueStatus { open, working, resolved }

enum IssueSeverity { low, medium, high, critical }

class IssueModel {
  final String id;
  final String title;
  final String description;
  final String groupId;
  final List<String> assignedTo;
  final String reportedBy;
  final IssueStatus status;
  final IssueSeverity severity;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.groupId,
    required this.assignedTo,
    required this.reportedBy,
    required this.status,
    required this.severity,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'groupId': groupId,
      'assignedTo': assignedTo,
      'reportedBy': reportedBy,
      'status': status.name,
      'severity': severity.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      groupId: json['groupId'] as String,
      assignedTo: List<String>.from(json['assignedTo'] ?? []),
      reportedBy: json['reportedBy'] as String,
      status: IssueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IssueStatus.open,
      ),
      severity: IssueSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => IssueSeverity.medium,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      resolvedAt: (json['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }
}
