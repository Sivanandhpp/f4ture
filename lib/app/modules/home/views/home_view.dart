import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/index.dart';
import '../../../data/services/auth_service.dart';
import '../../navigation/controllers/navigation_controller.dart';
import '../../event_schedule/views/event_details_view.dart';
import '../../event_schedule/widgets/cyberpunk_event_card.dart';
import '../controllers/home_controller.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/futuristic_background.dart';
import '../widgets/home_action_card.dart';
import '../widgets/live_now_widget.dart';
import '../widgets/video_background.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: HomeView extends GetView<HomeController>, but we are using AuthService here directly.

    final user = AuthService.to.currentUser.value;

    return Scaffold(
      body: Stack(
        children: [
          // 0. Base Background (Fixed)
          const Positioned.fill(child: FuturisticBackground()),

          // Scrollable Content
          SingleChildScrollView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                // Video Background (Scrolls with content)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Obx(
                      () => VideoBackground(
                        videoPath: 'assets/videos/highlights.mp4',
                        shouldPlay: controller.isVideoVisible.value,
                      ),
                    ),
                  ),
                ),

                // Foreground Content
                SafeArea(
                  child: Column(
                    children: [
                      // Custom App Bar
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Profile Picture
                            GestureDetector(
                              onTap: () {
                                try {
                                  if (user?.role == 'attendee') {
                                    Get.toNamed(Routes.USER_PROFILE);
                                  } else {
                                    Get.toNamed(Routes.ADMIN_CONSOLE);
                                  }
                                } catch (e) {
                                  debugPrint('Navigation error: $e');
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: user?.profilePhoto != null
                                      ? NetworkImage(user!.profilePhoto!)
                                      : null,
                                  backgroundColor: Colors.grey.shade900,
                                  child: user?.profilePhoto == null
                                      ? Text(
                                          user?.name != null &&
                                                  user!.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),

                            // Center Text
                            Column(
                              children: [
                                Text(
                                  'Welcome to',
                                  style: AppFont.caption.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 1.5,
                                    fontSize: 12,
                                  ),
                                ),
                                AppImage.asset(
                                  path: 'assets/images/futuretext.png',
                                  height: 25,
                                ),
                              ],
                            ),

                            // Notification Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.scaffolditems,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 140),
                      // Dynamic Home Content
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Obx(() {
                          if (controller.homeState.value ==
                              HomeState.countdown) {
                            return CountdownWidget(
                              timeLeft: controller.timeLeftStr.value,
                            );
                          } else if (controller.homeState.value ==
                              HomeState.live) {
                            return LiveNowWidget(
                              dayLabel: controller.currentDayLabel.value,
                              currentEvent: controller.currentEvent.value,
                              nextEvent: controller.nextEvent.value,
                              nextEventTimeLeft:
                                  controller.nextEventTimeLeft.value,
                            );
                          } else {
                            // Post Event
                            return const Center(
                              child: Text(
                                'See you next year! 🚀',
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }
                        }),
                      ),
                      const SizedBox(height: 12),
                      // Action Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            HomeActionCard(
                              title: 'Navigate\nto Future',
                              imagePath: 'assets/images/navigatefuture.png',
                              onTap: () {
                                try {
                                  Get.find<NavigationController>().changeTab(
                                    3,
                                  ); // Map Tab
                                } catch (_) {
                                  Get.snackbar(
                                    'Coming Soon',
                                    'Event Map is currently available for attendees.',
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            HomeActionCard(
                              title: 'Share your\nmoments',
                              imagePath: 'assets/images/sharemoments.png',
                              onTap: () => Get.toNamed(Routes.CREATE_POST),
                            ),
                            const SizedBox(width: 12),
                            HomeActionCard(
                              title: 'Connect\nto Future',
                              imagePath: 'assets/images/connectfuture.png',
                              onTap: () {
                                try {
                                  Get.find<NavigationController>().changeTab(
                                    2,
                                  ); // Feed Tab
                                } catch (_) {
                                  // Fallback or generic navigation
                                  Get.snackbar(
                                    'Coming Soon',
                                    'Future Feed is currently available for attendees.',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Filter Chips
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children:
                              [
                                'Featured',
                                'Concerts',
                                'Day 1',
                                'Day 2',
                                'Day 3',
                                'Day 4',
                              ].map((filter) {
                                return Obx(() {
                                  final isSelected =
                                      controller.selectedFilter.value == filter;
                                  return GestureDetector(
                                    onTap: () => controller.setFilter(filter),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
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
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.4),
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
                              }).toList(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Horizontal Event List
                      SizedBox(
                        height: 220, // Height for Cyberpunk Card
                        child: Obx(() {
                          final events = controller.filteredEvents;
                          if (events.isEmpty) {
                            return const Center(
                              child: Text(
                                'No events found.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: events.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return CyberpunkEventCard(
                                event: event,
                                width: 160, // Slightly wider for home
                                onTap: () {
                                  Get.to(() => EventDetailsView(event: event));
                                },
                              );
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 100),
                    ],
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
