import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/auth_service.dart';
import '../../navigation/controllers/navigation_controller.dart';
import '../controllers/feed_controller.dart';
import 'media_carousel.dart';

class FeedPostItem extends StatefulWidget {
  final PostModel post;

  const FeedPostItem({super.key, required this.post});

  @override
  State<FeedPostItem> createState() => _FeedPostItemState();
}

class _FeedPostItemState extends State<FeedPostItem> {
  final FeedController controller = Get.find();
  bool isHeartAnimating = false;

  static const Color kSurface = Color(0xFF1E1E1E);
  static const Color kTextPrimary = Colors.white;
  static const Color kTextSecondary = Color(0xFFAAAAAA);

  void _handleDoubleTap() {
    setState(() {
      isHeartAnimating = true;
    });

    if (!widget.post.isLikedByMe) {
      controller.toggleLike(widget.post);
    }

    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          isHeartAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(widget.post.authorAvatar),
                  backgroundColor: Colors.grey[800],
                  onBackgroundImageError: (_, __) =>
                      const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeago.format(widget.post.createdAt),
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                          if (widget.post.type == PostType.blog) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BLOG',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: kTextSecondary),
                  onPressed: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final currentUserModel =
                        Get.find<AuthService>().currentUser.value;

                    final isAuthor = currentUser?.uid == widget.post.authorId;
                    final isAdmin = currentUserModel?.role == 'admin';

                    if (isAuthor || isAdmin) {
                      Get.bottomSheet(
                        Container(
                          color: kSurface,
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Delete Post',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Get.back(); // Close sheet
                                  Get.dialog(
                                    Dialog(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1E1E),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red,
                                                size: 32,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Delete Post?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'This action cannot be undone.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () => Get.back(),
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        side: BorderSide(
                                                          color: Colors.white
                                                              .withOpacity(0.1),
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back(); // Close dialog
                                                      controller.deletePost(
                                                        widget.post,
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Report or other options
                      Get.snackbar(
                        'Options',
                        'Report functionality coming soon',
                      );
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Caption (Top)
          if (widget.post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 16, right: 16),
              child: Text(
                widget.post.text,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

          // 3. Media (Rounded & Bordered)
          if (widget.post.mediaUrls.isNotEmpty)
            GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: VisibilityDetector(
                      key: Key(widget.post.postId),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction > 0.7) {
                          // Debounce or just set logic
                          // Only update if not already set to avoid constant updates
                          if (controller.visiblePostId.value !=
                              widget.post.postId) {
                            controller.visiblePostId.value = widget.post.postId;
                          }
                        }
                      },
                      child: Obx(() {
                        final navIndex =
                            Get.find<NavigationController>().tabIndex.value;
                        final isFeedTab = navIndex == 1;
                        final isFocused =
                            controller.visiblePostId.value ==
                            widget.post.postId;
                        return MediaCarousel(
                          mediaUrls: widget.post.mediaUrls,
                          thumbnailUrl: widget.post.thumbnailUrl,
                          shouldPlay: isFocused && isFeedTab,
                        );
                      }),
                    ),
                  ),
                  if (isHeartAnimating)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 100,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 4. Interaction Bar
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 16, right: 16),
            child: Row(
              children: [
                _buildInteractionButton(
                  icon: widget.post.isLikedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.isLikedByMe ? Colors.red : kTextPrimary,
                  label: '${widget.post.likesCount}',
                  onTap: () => controller.toggleLike(widget.post),
                ),
                const SizedBox(width: 20),
                _buildInteractionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: kTextPrimary,
                  label: '${widget.post.commentsCount}',
                  onTap: () => controller.openComments(widget.post),
                ),
                const SizedBox(width: 20),
                // Share (Placeholder)
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
