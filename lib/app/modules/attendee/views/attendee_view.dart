import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../feed/views/feed_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/attendee_controller.dart';
import '../widgets/attendee_glass_navbar.dart';
import '../../super_home/views/tabs/chats_tab.dart';
import 'tabs/event_map_tab.dart';
import 'tabs/event_schedule_tab.dart';

class AttendeeView extends GetView<AttendeeController> {
  const AttendeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Dark background for contrast with glass navbar
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
                EventMapTab(),
                EventScheduleTab(),
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
