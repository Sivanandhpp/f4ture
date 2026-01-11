import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shimmer/shimmer.dart';

/// Centralized video player for both network & asset videos with loading state,
/// controls, and optional autoplay.
class AppVideo extends StatefulWidget {
  final String source;
  final bool isNetwork;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool muted;
  final bool isBackground;
  final double aspectRatio;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppVideo._({
    required this.source,
    required this.isNetwork,
    this.width,
    this.height,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.muted = false,
    this.isBackground = false,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  /// Network video with controls and loading state.
  factory AppVideo.network({
    required String url,
    double? width,
    double? height,
    bool autoPlay = false,
    bool looping = false,
    bool showControls = true,
    bool muted = false,
    double aspectRatio = 16 / 9,
    BoxFit fit = BoxFit.contain,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    Key? key,
  }) {
    return AppVideo._(
      source: url,
      isNetwork: true,
      width: width,
      height: height,
      autoPlay: autoPlay,
      looping: looping,
      showControls: showControls,
      muted: muted,
      aspectRatio: aspectRatio,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      key: key,
    );
  }

  /// Asset video with consistent API to network.
  factory AppVideo.asset({
    required String path,
    double? width,
    double? height,
    bool autoPlay = false,
    bool looping = false,
    bool showControls = true,
    bool muted = false,
    double aspectRatio = 16 / 9,
    BoxFit fit = BoxFit.contain,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    Key? key,
  }) {
    return AppVideo._(
      source: path,
      isNetwork: false,
      width: width,
      height: height,
      autoPlay: autoPlay,
      looping: looping,
      showControls: showControls,
      muted: muted,
      aspectRatio: aspectRatio,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      key: key,
    );
  }

  /// Background video - auto-plays, loops, muted, no controls.
  factory AppVideo.background({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Key? key,
  }) {
    return AppVideo._(
      source: assetPath,
      isNetwork: false,
      width: width,
      height: height,
      autoPlay: true,
      looping: true,
      showControls: false,
      muted: true,
      isBackground: true,
      aspectRatio: 16 / 9,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      key: key,
    );
  }

  /// Background video from network - auto-plays, loops, muted, no controls.
  factory AppVideo.backgroundNetwork({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Key? key,
  }) {
    return AppVideo._(
      source: url,
      isNetwork: true,
      width: width,
      height: height,
      autoPlay: true,
      looping: true,
      showControls: false,
      muted: true,
      isBackground: true,
      aspectRatio: 16 / 9,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      key: key,
    );
  }

  @override
  State<AppVideo> createState() => _AppVideoState();
}

class _AppVideoState extends State<AppVideo> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.isNetwork) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.source),
        );
      } else {
        _videoController = VideoPlayerController.asset(widget.source);
      }

      await _videoController.initialize();

      if (widget.muted) {
        _videoController.setVolume(0);
      }

      if (widget.looping) {
        _videoController.setLooping(true);
      }

      if (widget.autoPlay) {
        _videoController.play();
      }

      // Only create Chewie controller if we need controls
      if (widget.showControls && !widget.isBackground) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: widget.autoPlay,
          looping: widget.looping,
          showControls: widget.showControls,
          aspectRatio: widget.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return _buildErrorWidget();
          },
        );
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_hasError) {
      content = _buildErrorWidget();
    } else if (!_isInitialized) {
      content = _buildPlaceholder();
    } else if (widget.isBackground || !widget.showControls) {
      // For background videos, fill the container and crop as needed
      final videoSize = _videoController.value.size;
      content = LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale to fill width (horizontal)
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;

          double scale;
          if (widget.fit == BoxFit.cover) {
            // Scale to cover the entire container
            final scaleX = containerWidth / videoSize.width;
            final scaleY = containerHeight / videoSize.height;
            scale = scaleX > scaleY ? scaleX : scaleY;
          } else {
            // Default contain behavior
            final scaleX = containerWidth / videoSize.width;
            final scaleY = containerHeight / videoSize.height;
            scale = scaleX < scaleY ? scaleX : scaleY;
          }

          return ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: videoSize.width * scale,
                height: videoSize.height * scale,
                child: VideoPlayer(_videoController),
              ),
            ),
          );
        },
      );
    } else {
      content = Chewie(controller: _chewieController!);
    }

    Widget sized;
    if (widget.isBackground) {
      // For background, fill the available space
      sized = SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    } else {
      sized = SizedBox(
        width: widget.width,
        height: widget.height,
        child: AspectRatio(aspectRatio: widget.aspectRatio, child: content),
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: sized);
    }

    return sized;
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    if (widget.isBackground) {
      return Container(color: Colors.black);
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Failed to load video', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
