import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import '../../../../main.dart'; // To access routeObserver
import '../controllers/feed_controller.dart';
import 'expanded_video_view.dart';

class VideoPostPlayer extends StatefulWidget {
  final String videoUrl;
  final bool shouldPlay;

  const VideoPostPlayer({
    super.key,
    required this.videoUrl,
    this.shouldPlay = false,
  });

  @override
  State<VideoPostPlayer> createState() => _VideoPostPlayerState();
}

class _VideoPostPlayerState extends State<VideoPostPlayer> with RouteAware {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isMuted = true;
  bool _wasPlayingBeforePause = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.setVolume(0.0); // Muted by default
          _controller.setLooping(true);
          if (widget.shouldPlay) {
            _controller.play();
          }
        });
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() {
    // Route was pushed onto navigator and is now covering this route.
    if (_initialized && _controller.value.isPlaying) {
      _wasPlayingBeforePause = true;
      _controller.pause();
    }
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    if (_initialized && _wasPlayingBeforePause && widget.shouldPlay) {
      _controller.play();
      _wasPlayingBeforePause = false;
    }
  }

  @override
  void didUpdateWidget(VideoPostPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay != oldWidget.shouldPlay && _initialized) {
      if (widget.shouldPlay) {
        // Only play if we are the top route
        if (ModalRoute.of(context)?.isCurrent ?? true) {
          _controller.play();
        } else {
          _wasPlayingBeforePause = true; // Mark to play when we return
        }
      } else {
        _controller.pause();
        _wasPlayingBeforePause = false;
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _openFullScreen() {
    final FeedController feedController = Get.find<FeedController>();

    // Filter posts that are videos (simplified logic: has media)
    // ideally check post type or media extension, reusing controller logic or model type
    // checking if mediaUrls has video extensions
    final videoPosts = feedController.posts.where((p) {
      if (p.mediaUrls.isEmpty) return false;
      final url = p.mediaUrls.first.toLowerCase();
      // Simplistic check, same as in carousel
      return url.contains('.mp4') || url.contains('.mov');
    }).toList();

    // Find index of current video
    // Note: widget.videoUrl is just one url. We need to find the post that contains this URL.
    // This is slightly inefficient but safe given we don't pass PostModel here yet.
    final initialIndex = videoPosts.indexWhere(
      (p) => p.mediaUrls.contains(widget.videoUrl),
    );

    if (initialIndex != -1) {
      Get.to(
        () => ExpandedVideoView(
          videoPosts: videoPosts,
          initialIndex: initialIndex,
        ),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white24),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Video Layer (Crop to Cover 4:5 or Parent constraints)
        // Parent is usually AspectRatio(4/5) in MediaCarousel
        GestureDetector(
          onTap: _openFullScreen,
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),

        // 2. Mute/Unmute Button (Bottom Right)
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: _toggleMute,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
