import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String iconUrl;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int membersCount;
  final String type; // public, private, committee
  final int unreadCount;

  GroupModel({
    required this.groupId,
    required this.name,
    required this.iconUrl,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.membersCount,
    required this.type,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'iconUrl': iconUrl,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'membersCount': membersCount,
      'type': type,
      'unreadCount': unreadCount,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastMessage: json['lastMessage'] as String,
      lastMessageAt: (json['lastMessageAt'] as Timestamp).toDate(),
      membersCount: json['membersCount'] as int,
      type: json['type'] as String,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  GroupModel copyWith({
    String? groupId,
    String? name,
    String? iconUrl,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? membersCount,
    String? type,
    int? unreadCount,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      membersCount: membersCount ?? this.membersCount,
      type: type ?? this.type,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
