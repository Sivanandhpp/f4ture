import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPreview extends StatefulWidget {
  final File file;

  const LocalVideoPreview({super.key, required this.file});

  @override
  State<LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<LocalVideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _initialized = true;
                _controller.setVolume(0); // Preview muted
                _controller.play();
                _controller.setLooping(true);
              });
            }
          })
          .catchError((e) {
            debugPrint("Error initializing video preview: $e");
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
