import 'package:get/get.dart';

import '../controllers/event_schedule_controller.dart';

class EventScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventScheduleController>(
      () => EventScheduleController(),
    );
  }
}
