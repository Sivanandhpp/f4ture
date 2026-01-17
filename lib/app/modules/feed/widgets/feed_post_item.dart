import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
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
                  onPressed: () {},
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
                    child: MediaCarousel(
                      mediaUrls: widget.post.mediaUrls,
                      thumbnailUrl: widget.post.thumbnailUrl,
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
