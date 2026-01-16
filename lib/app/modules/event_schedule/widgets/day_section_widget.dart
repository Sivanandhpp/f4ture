import 'package:flutter/material.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/data/models/event_model.dart';
import 'cyberpunk_event_card.dart';
import '../views/event_details_view.dart';
import 'package:get/get.dart';

/// A widget that displays a horizontal list of events for a specific day.
/// Features a vertical "DAY X" label on the left side.
class DaySectionWidget extends StatelessWidget {
  final int dayNumber;
  final List<EventModel> events;

  const DaySectionWidget({
    super.key,
    required this.dayNumber,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: SizedBox(
        height: 220, // Reduced height for the smaller card
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Vertical Day Label
            _buildVerticalDayLabel(),
            // Right: Horizontal List
            ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 80, right: 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return CyberpunkEventCard(
                  event: events[index],
                  onTap: () {
                    Get.to(() => EventDetailsView(event: events[index]));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDayLabel() {
    return Container(
      width: 100,
      alignment: Alignment.center,
      child: Text(
        '$dayNumber',
        style: TextStyle(
          fontSize: 160,
          fontFamily: 'Valorax',
          height: 1, // Minimize vertical padding
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = AppColors.scaffolditems,
          shadows: [
            Shadow(
              color: AppColors.primaryLight.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }
}
