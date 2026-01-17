import 'package:f4ture/app/core/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../feed/views/feed_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/navigation_glass_navbar.dart';
import '../../chat/views/chats_list.dart';
import '../../event_map/views/event_map_view.dart';
import '../../event_schedule/views/event_schedule_view.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.tabIndex.value == 0,
        onPopInvoked: (didPop) {
          if (didPop) return;
          controller.changeTab(0);
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldbg,
          body: Stack(
            children: [
              // 1. Main Content
              IndexedStack(
                index: controller.tabIndex.value,
                children: [
                  HomeView(),
                  FeedView(),
                  ChatsList(),
                  const EventMapView(),
                  const EventScheduleView(),
                ],
              ),

              // 2. Floating Navbar
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: NavigationGlassNavbar(
                    currentIndex: controller.tabIndex.value,
                    onTap: controller.changeTab,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
