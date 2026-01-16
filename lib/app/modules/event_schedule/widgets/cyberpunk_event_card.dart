import 'package:flutter/material.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/event_model.dart';

/// A reusable event card that displays only the event image in a 4:5 aspect ratio.
/// This mimics the Instagram post style, focusing entirely on visual content.
class CyberpunkEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final double width;

  const CyberpunkEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.width = 160, // Default width
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: AppColors.appbarbg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.2),
          highlightColor: AppColors.primary.withOpacity(0.1),
          child: AspectRatio(
            aspectRatio: 4 / 5, // Instagram Portrait Aspect Ratio
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Event Image
                if (event.imageUrl != null)
                  Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey.shade900,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey.shade900,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.event,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),

                // Subtle inner border (optional, adds to cyberpunk feel)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
