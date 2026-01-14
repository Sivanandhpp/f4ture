import 'package:f4ture/app/modules/chat/controllers/chat_controller.dart';
import 'package:f4ture/app/modules/super_home/controllers/super_home_controller.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../feed/controllers/feed_controller.dart';
import '../controllers/attendee_controller.dart';

class AttendeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendeeController>(() => AttendeeController());
    Get.lazyPut<SuperHomeController>(() => SuperHomeController());
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
