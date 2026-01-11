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
    );
  }
}
