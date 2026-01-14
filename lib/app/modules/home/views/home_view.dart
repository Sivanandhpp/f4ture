import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/index.dart';
import '../../../data/services/auth_service.dart';
import '../../super_home/controllers/super_home_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/futuristic_background.dart';
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
                          top: 20,
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
                                Text(
                                  'FUTURE',
                                  style: AppFont.heading.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.primary.withOpacity(
                                          0.8,
                                        ),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
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
                                color: AppColors.primary, // Yellow/Primary tint
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 150),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeonButton(
                            text: 'Get Tickets',
                            onTap: () {},
                            glowColor: AppColors.primaryLight, // Cyan
                          ),
                          const SizedBox(width: 20),
                          NeonButton(
                            text: 'Explore',
                            onTap: () {},
                            glowColor: AppColors.info, // Purple
                          ),
                        ],
                      ),

                      // Placeholder for scrollable content
                      // Replacing Spacer with Fixed Height to enable scrolling demonstration
                      const SizedBox(height: 600),

                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Text(
                          "Coming Soon\nMore interactive features...",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),

                      const SizedBox(height: 100), // Extra bottom padding
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
