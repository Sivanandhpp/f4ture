import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/services/auth_service.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    // Custom Dark Colors
    const Color kSurface = Color(0xFF1E1E1E);
    const Color kInputBackground = Color(0xFF2C2C2C);
    const Color kTextPrimary = Colors.white;
    const Color kTextSecondary = Color(0xFFAAAAAA);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 48,
                  ), // Spacer to balance the close button
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: kTextPrimary),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Colors.white24),

              // Comments List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet. Be the first!',
                          style: TextStyle(color: kTextSecondary),
                        ),
                      );
                    }

                    final comments = snapshot.data!.docs
                        .map(
                          (doc) => CommentModel.fromJson(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList();

                    return ListView.separated(
                      controller: controller, // Essential for DraggableSheet
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(comment.userAvatar),
                              backgroundColor: Colors.grey[800],
                              onBackgroundImageError: (_, __) {},
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: kTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeago.format(comment.createdAt),
                                        style: const TextStyle(
                                          color: kTextSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(color: kTextPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Input
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kSurface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, -2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          AuthService.to.currentUser.value?.profilePhoto ?? '',
                        ),
                        backgroundColor: Colors.grey[800],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: kInputBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: kTextPrimary),
                            cursorColor: AppColors.primary,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: kTextSecondary),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isPosting ? null : _postComment,
                        child: _isPosting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Text(
                                'Post',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
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
      },
    );
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.to.currentUser.value;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      final commentId = const Uuid().v4(); // Need uuid package
      // Wait, we don't have uuid setup here or maybe we use Firestore auto-id?
      // Let's use Firestore auto-id for simplicity in subcollections

      final postRef = _firestore.collection('posts').doc(widget.postId);
      final commentRef = postRef.collection('comments').doc();

      final comment = CommentModel(
        commentId: commentRef.id,
        userId: user.id,
        userName: user.name,
        userAvatar: user.profilePhoto ?? '',
        text: text,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.set(commentRef, comment.toJson());
      batch.update(postRef, {'commentsCount': FieldValue.increment(1)});

      await batch.commit();

      _commentController.clear();
      FocusScope.of(context).unfocus(); // Close keyboard
    } catch (e) {
      Get.snackbar('Error', 'Failed to post comment');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }
}
