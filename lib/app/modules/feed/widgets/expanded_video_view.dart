import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../controllers/feed_controller.dart';

class ExpandedVideoView extends StatefulWidget {
  final List<PostModel> videoPosts;
  final int initialIndex;

  const ExpandedVideoView({
    super.key,
    required this.videoPosts,
    required this.initialIndex,
  });

  @override
  State<ExpandedVideoView> createState() => _ExpandedVideoViewState();
}

class _ExpandedVideoViewState extends State<ExpandedVideoView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videoPosts.length,
        itemBuilder: (context, index) {
          return TikTokVideoPage(post: widget.videoPosts[index]);
        },
      ),
    );
  }
}

class TikTokVideoPage extends StatefulWidget {
  final PostModel post;

  const TikTokVideoPage({super.key, required this.post});

  @override
  State<TikTokVideoPage> createState() => _TikTokVideoPageState();
}

class _TikTokVideoPageState extends State<TikTokVideoPage> {
  late VideoPlayerController _controller;
  final FeedController feedController = Get.find<FeedController>();
  bool _initialized = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // Assuming first media URL is the video for simplicity in this view
    final videoUrl = widget.post.mediaUrls.first;
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
            _controller.setVolume(1.0); // Sound ON by default
            _controller.play();
            _controller.setLooping(true);
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video Player
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            color: Colors.black,
            child: Center(
              child: _initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ),

        // Play/Pause Icon Overlay
        if (!_isPlaying)
          const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 64,
              color: Colors.white54,
            ),
          ),

        // 2. Back Button (Top Left)
        Positioned(
          top: 48,
          left: 16,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Get.back(),
          ),
        ),

        // 3. Right Side Actions (Like, Comment, etc)
        Positioned(
          bottom: 100,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like
              Obx(() {
                // Re-fetch post from controller to get latest reactive state if needed,
                // but simpler to use post model passed in if updated
                // or wrap in Obx if the list in controller matches.
                // For now, using widget.post status, but might need to listen to controller update.
                // Since we are inside a PageView, rebuilding might be tricky.
                // Ideally, we'd observe the specific post in the controller.
                final currentPost = feedController.posts.firstWhere(
                  (p) => p.postId == widget.post.postId,
                  orElse: () => widget.post,
                );

                return _buildActionItem(
                  icon: currentPost.isLikedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentPost.isLikedByMe ? Colors.red : Colors.white,
                  label: '${currentPost.likesCount}',
                  onTap: () => feedController.toggleLike(currentPost),
                );
              }),
              const SizedBox(height: 20),

              // Comment
              _buildActionItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${widget.post.commentsCount}',
                onTap: () => feedController.openComments(widget.post),
              ),
              const SizedBox(height: 20),

              // // Share (Placeholder)
              // _buildActionItem(
              //   icon: Icons.share_rounded,
              //   label: 'Share',
              //   onTap: () {},
              // ),
              // const SizedBox(height: 20),

              // // More
              // _buildActionItem(
              //   icon: Icons.more_horiz_rounded,
              //   label: '',
              //   onTap: () {},
              // ),
            ],
          ),
        ),

        // 4. Bottom Info (User, Caption)
        Positioned(
          bottom: 24,
          left: 16,
          right: 80, // Leave room for right actions
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.post.authorAvatar),
                    backgroundColor: Colors.grey[800],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.post.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // Follow Button (Mock)
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 8,
                  //     vertical: 2,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.white),
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   child: const Text(
                  //     'Follow',
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),

              // Caption
              if (widget.post.text.isNotEmpty)
                Text(
                  widget.post.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              const SizedBox(height: 4),

              // Time / Music Info
              Row(
                children: [
                  const Icon(Icons.music_note, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Original Audio • ${timeago.format(widget.post.createdAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 5. Progress Bar
        if (_initialized)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.grey,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
