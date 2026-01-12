import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { post, blog, reel }

class PostModel {
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final PostType type;
  final String text; // Caption or Blog Content
  final List<String> mediaUrls;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe; // Local UI state, not stored in main doc usually

  PostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.type,
    required this.text,
    required this.mediaUrls,
    this.thumbnailUrl,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'type': type.name,
      'text': text,
      'mediaUrls': mediaUrls,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      // 'isLikedByMe' is excluded from JSON as it's per-user state,
      // handled via subcollections or separate queries usually.
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Unknown',
      authorAvatar: json['authorAvatar'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      text: json['text'] as String? ?? '',
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLikedByMe: false, // Default, will be updated by controller
    );
  }

  static PostType _parseType(String? type) {
    return PostType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => PostType.post,
    );
  }

  PostModel copyWith({
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    PostType? type,
    String? text,
    List<String>? mediaUrls,
    String? thumbnailUrl,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
