import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../../../data/services/auth_service.dart';
import '../../super_home/controllers/super_home_controller.dart';
import '../../attendee/controllers/attendee_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/futuristic_background.dart';
import '../widgets/home_action_card.dart';
import '../widgets/live_now_widget.dart';
import '../widgets/neon_button.dart';
import '../widgets/video_background.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
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
                                  Get.toNamed(Routes.USER_PROFILE);
                                } catch (e) {
                                  debugPrint(
                                    'SuperHomeController not found: $e',
                                  );
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

                      const SizedBox(height: 120),

                      // Dynamic Home Content
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
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

                      const SizedBox(height: 24),

                      // Action Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            HomeActionCard(
                              title: 'Navigate\nto Future',
                              imagePath: 'assets/images/vishayam.png',
                              onTap: () {
                                try {
                                  Get.find<AttendeeController>().changeTab(
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
                              imagePath: 'assets/images/vishayam.png',
                              onTap: () => Get.toNamed(Routes.CREATE_POST),
                            ),
                            const SizedBox(width: 12),
                            HomeActionCard(
                              title: 'Connect\nto Future',
                              imagePath: 'assets/images/vishayam.png',
                              onTap: () {
                                try {
                                  Get.find<AttendeeController>().changeTab(
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
