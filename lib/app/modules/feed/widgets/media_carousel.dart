import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'video_post_player.dart';

class MediaCarousel extends StatefulWidget {
  final List<String> mediaUrls;
  final String? thumbnailUrl;
  final bool shouldPlay;

  const MediaCarousel({
    super.key,
    required this.mediaUrls,
    this.thumbnailUrl,
    this.shouldPlay = false,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5, // 4:5 Instagram style (Vertical)
          child: PageView.builder(
            itemCount: widget.mediaUrls.length,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.mediaUrls[index];

              final uri = Uri.parse(url);
              final path = uri.path.toLowerCase();
              final isVideo = path.contains('.mp4') || path.contains('.mov');

              if (isVideo) {
                // Only play if the carousel is active AND this specific page is active
                final isCurrentPage = index == _current;
                return VideoPostPlayer(
                  videoUrl: url,
                  shouldPlay: widget.shouldPlay && isCurrentPage,
                );
              }

              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            },
          ),
        ),
        if (widget.mediaUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.mediaUrls.asMap().entries.map((entry) {
                return Container(
                  width: 6.0,
                  height: 6.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == entry.key
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
