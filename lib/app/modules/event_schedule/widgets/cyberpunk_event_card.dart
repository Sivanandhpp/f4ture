import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:f4ture/app/data/models/event_model.dart';

/// A reusable event card with a Material-Cyberpunk fusion aesthetic.
/// Features a clean Card layout with ripple effects, high contrast text,
/// and subtle neon accents.
class CyberpunkEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final double width;

  const CyberpunkEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.width = 220, // Smaller width as requested
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: AppColors.appbarbg, // Dark solid background for material feel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Section (Top Half)
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                          size: 40,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),

                    // Gradient for text readability over image if needed
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Price Tag (Material Chip style)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.ticketPrice > 0
                              ? '${event.currency} ${event.ticketPrice.toInt()}'
                              : 'Free',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Info Section (Bottom Half)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.heading.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // High contrast white
                          height: 1.2,
                        ),
                      ),

                      const Spacer(),

                      // Details Row
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${DateFormat('h:mm a').format(event.startTime)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venue,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
