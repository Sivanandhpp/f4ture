import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../controllers/feed_controller.dart';
import 'media_carousel.dart';

class FeedPostItem extends StatelessWidget {
  final PostModel post;
  final FeedController controller = Get.find(); // Find existing or pass in

  FeedPostItem({super.key, required this.post});

  // Custom Dark Colors
  static const Color kSurface = Color(0xFF1E1E1E);
  static const Color kTextPrimary = Colors.white;
  static const Color kTextSecondary = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(post.authorAvatar),
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
                        post.authorName,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (post.type == PostType.blog)
                        Text(
                          'Blog Article',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: kTextSecondary),
                  onPressed: () {}, // Report/Menu options
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Content Helper (Media)
          if (post.mediaUrls.isNotEmpty)
            MediaCarousel(
              mediaUrls: post.mediaUrls,
              thumbnailUrl: post.thumbnailUrl,
            ),

          // Interaction Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () => controller.toggleLike(post),
                  child: Icon(
                    post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.isLikedByMe ? Colors.red : kTextPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => controller.openComments(post),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: kTextPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.send_rounded, color: kTextPrimary, size: 24),
                const Spacer(),
                if (post.type == PostType.blog)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "READ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Counts & Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.likesCount > 0)
                  Text(
                    '${post.likesCount} likes',
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                const SizedBox(height: 4),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: kTextPrimary, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '${post.authorName} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: post.text),
                    ],
                  ),
                ),

                if (post.commentsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: GestureDetector(
                      onTap: () => controller.openComments(post),
                      child: Text(
                        'View all ${post.commentsCount} comments',
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    timeago.format(post.createdAt),
                    style: const TextStyle(color: kTextSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
