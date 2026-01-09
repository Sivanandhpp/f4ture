import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/widgets/app_image.dart';
import 'package:f4ture/app/core/widgets/app_video.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Background Video
            Positioned.fill(
              child: AppVideo.background(
                assetPath: 'assets/videos/future_summit_videoBG.mp4',
                // borderRadius: BorderRadius.circular(24),
              ),
            ),

            // Dark overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Welcome text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The Summit of Future',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                        // Profile icon
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.PROFILE),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.background,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 20),

                    // Banner image
                    AppImage.asset(
                      path: 'assets/images/banner.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 180,
          child: AppVideo.background(
            assetPath: 'assets/videos/FutureSummit_heilights.mp4',
          ),
        ),
      ],
    );
  }
}
