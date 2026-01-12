import 'package:get/get.dart';

import '../../feed/controllers/feed_controller.dart';
import '../controllers/attendee_controller.dart';

class AttendeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendeeController>(() => AttendeeController());
    Get.lazyPut<FeedController>(() => FeedController());
  }
}
