import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, file, info }

enum MessageStatus { pending, sent, delivered, read, error }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final String? mediaName;
  final int? mediaSize;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    this.text,
    this.mediaUrl,
    this.mediaName,
    this.mediaSize,
    this.thumbnailUrl,
    required this.createdAt,
    this.status = MessageStatus.sent,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      senderAvatar: json['senderAvatar'],
      type: _parseType(json['type']),
      text: json['text'],
      mediaUrl: json['mediaUrl'],
      mediaName: json['mediaName'],
      mediaSize: json['mediaSize'],
      thumbnailUrl: json['thumbnailUrl'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.name,
      'text': text,
      'mediaUrl': mediaUrl,
      'mediaName': mediaName,
      'mediaSize': mediaSize,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  static MessageType _parseType(String? type) {
    return MessageType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => MessageType.text,
    );
  }

  static MessageStatus _parseStatus(String? status) {
    return MessageStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => MessageStatus.sent,
    );
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    String? text,
    String? mediaUrl,
    String? mediaName,
    int? mediaSize,
    String? thumbnailUrl,
    DateTime? createdAt,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaName: mediaName ?? this.mediaName,
      mediaSize: mediaSize ?? this.mediaSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
