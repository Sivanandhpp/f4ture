import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/index.dart';
import '../controllers/home_controller.dart';
import 'tabs/events_view.dart';
import 'tabs/feed_view.dart';
import 'tabs/home_tab_view.dart';
import 'tabs/map_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // List of tab pages
  static const List<Widget> _pages = [
    HomeTabView(),
    EventsView(),
    FeedView(),
    MapView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: _pages[controller.currentIndex.value],
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          indicatorColor: AppColors.primary,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 28),
              selectedIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined, size: 28),
              selectedIcon: Icon(Icons.event, size: 28),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.feed_outlined, size: 28),
              selectedIcon: Icon(Icons.feed, size: 28),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, size: 28),
              selectedIcon: Icon(Icons.map, size: 28),
              label: 'Map',
            ),
          ],
        ),
      ),
    );
  }
}
