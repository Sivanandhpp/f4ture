import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import '../controllers/event_schedule_controller.dart';
import '../widgets/day_section_widget.dart';

class EventScheduleView extends GetView<EventScheduleController> {
  const EventScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized if not already
    Get.put(EventScheduleController());

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
                  vertical: 16.0,
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.appbarbg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Events...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 14),
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.eventTypes.length,
                    itemBuilder: (context, index) {
                      final filter = controller.eventTypes[index];
                      return Obx(() {
                        final isSelected =
                            controller.selectedCategory.value == filter;
                        return GestureDetector(
                          onTap: () =>
                              controller.selectedCategory.value = filter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
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

              final eventsByDay = controller.eventsByDay;
              final hasEvents = eventsByDay.values.any(
                (list) => list.isNotEmpty,
              );

              if (!hasEvents) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.shade800,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? "No events match your search"
                              : "No upcoming events",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final day = index; // 0 to 4
                    final events = eventsByDay[day] ?? [];
                    if (events.isEmpty) return const SizedBox.shrink();

                    return DaySectionWidget(dayNumber: day, events: events);
                  },
                  childCount: 5, // 0 to 4 Days (5 total)
                ),
              );
            }),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  // Removed old _buildEventItem as it's replaced by DaySectionWidget and CyberpunkEventCard
}
