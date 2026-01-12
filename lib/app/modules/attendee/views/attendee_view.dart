import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import '../../feed/views/feed_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/attendee_controller.dart';
import '../widgets/attendee_glass_navbar.dart';
import 'tabs/community_tab.dart';
import 'tabs/event_map_tab.dart';
import 'tabs/event_schedule_tab.dart';

class AttendeeView extends GetView<AttendeeController> {
  const AttendeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Main Content
          Obx(
            () => IndexedStack(
              index: controller.tabIndex.value,
              children: [
                HomeView(),
                FeedView(),
                CommunityTab(),
                EventMapTab(),
                EventScheduleTab(),
              ],
            ),
          ),

          // 2. Floating Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => AttendeeGlassNavbar(
                currentIndex: controller.tabIndex.value,
                onTap: controller.changeTab,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
