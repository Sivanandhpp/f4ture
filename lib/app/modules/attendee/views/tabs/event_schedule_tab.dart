import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../data/models/event_model.dart';
import '../../../event_schedule/controllers/event_schedule_controller.dart';

class EventScheduleTab extends StatelessWidget {
  const EventScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller locally for this tab
    final controller = Get.put(EventScheduleController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: RefreshIndicator(
        onRefresh: () async => controller.refreshSchedule(),
        color: AppColors.primary,
        backgroundColor: AppColors.scaffoldbg,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.scaffoldbg,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, top: 16),
                title: Text(
                  'Event Schedule',
                  style: AppFont.heading.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.scaffolditems,
                  ),
                ),
              ),
              centerTitle: false,
              actions: [
                // Filter Icon placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IconButton(
                    onPressed: () {}, // Filter logic later
                    icon: Icon(
                      Icons.filter_list,
                      color: AppColors.scaffolditems,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Events',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 10),
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value && controller.events.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final events = controller.filteredEvents;

              if (events.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? "No events found"
                              : "No upcoming events",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = events[index];
                  return _buildEventItem(event);
                }, childCount: events.length),
              );
            }),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(EventModel event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appbarbg, // Dark card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Box
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('d').format(event.startTime),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(event.startTime).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.type.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
