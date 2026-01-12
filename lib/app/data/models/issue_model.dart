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

  IssueModel copyWith({
    String? id,
    String? title,
    String? description,
    String? groupId,
    List<String>? assignedTo,
    String? reportedBy,
    IssueStatus? status,
    IssueSeverity? severity,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return IssueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      assignedTo: assignedTo ?? this.assignedTo,
      reportedBy: reportedBy ?? this.reportedBy,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
