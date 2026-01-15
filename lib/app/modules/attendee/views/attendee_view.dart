import 'package:f4ture/app/core/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../feed/views/feed_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/attendee_controller.dart';
import '../widgets/attendee_glass_navbar.dart';
import '../../super_home/views/tabs/chats_tab.dart';
import '../../event_map/views/event_map_view.dart';
import '../../event_schedule/views/event_schedule_view.dart';

class AttendeeView extends GetView<AttendeeController> {
  const AttendeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors
          .scaffoldbg, // Dark background for contrast with glass navbar
      body: Stack(
        children: [
          // 1. Main Content
          Obx(
            () => IndexedStack(
              index: controller.tabIndex.value,
              children: [
                HomeView(),
                FeedView(),
                ChatsTab(),
                const EventMapView(),
                const EventScheduleView(),
              ],
            ),
          ),

          // 2. Floating Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Obx(
                () => AttendeeGlassNavbar(
                  currentIndex: controller.tabIndex.value,
                  onTap: controller.changeTab,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
