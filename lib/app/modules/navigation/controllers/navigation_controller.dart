import 'package:get/get.dart';

import '../../feed/controllers/feed_controller.dart';

class NavigationController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void changeTab(int index) {
    if (index == 1) {
      // Feed Tab
      try {
        final feedController = Get.find<FeedController>();
        feedController.refreshFeed();
      } catch (e) {
        // Controller might not be ready, though binding ensures it is
      }
    }
    tabIndex.value = index;
  }
}
