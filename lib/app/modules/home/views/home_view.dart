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
  Widget build(BuildContext context) {
    // Note: HomeView extends GetView<HomeController>, but we are using AuthService here directly.
    // If we want to use logic, we should put it in HomeController.
    // For now, this stateless-like UI using AuthService is fine.

    final user = AuthService.to.currentUser.value;

    return Scaffold(
      // backgroundColor: Colors.black, // Removed in favor of FuturisticBackground
      body: Stack(
        children: [
          // 0. Base Background
          const Positioned.fill(child: FuturisticBackground()),
          // Video Background (Foreground element underneath header)
          SafeArea(
            child: const Padding(
              padding: EdgeInsets.only(top: 50),
              child: VideoBackground(videoPath: 'assets/videos/highlights.mp4'),
            ),
          ),
          // 1. Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: () {
                          // Navigate to User Profile Tab (Index 3)
                          try {
                            Get.toNamed(Routes.USER_PROFILE);
                          } catch (e) {
                            debugPrint('SuperHomeController not found: $e');
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
                                    user?.name != null && user!.name.isNotEmpty
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
                                  color: AppColors.primary.withOpacity(0.8),
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
                SizedBox(height: 150),
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

                // Rest of the content (Space filler for now)
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
