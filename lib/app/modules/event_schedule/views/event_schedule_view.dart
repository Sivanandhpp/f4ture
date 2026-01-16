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
                  child: Obx(
                    () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.eventTypes.length,
                      itemBuilder: (context, index) {
                        final type = controller.eventTypes[index];
                        final isSelected =
                            controller.selectedCategory.value == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              controller.selectedCategory.value = type;
                            },
                            backgroundColor: AppColors.appbarbg,
                            selectedColor: AppColors.primary,
                            checkmarkColor: Colors.black,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        );
                      },
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
                    final day = index + 1; // 1 to 4
                    final events = eventsByDay[day] ?? [];
                    if (events.isEmpty) return const SizedBox.shrink();

                    return DaySectionWidget(dayNumber: day, events: events);
                  },
                  childCount: 4, // 4 Days
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
