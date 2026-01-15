import 'package:get/get.dart';

import '../controllers/event_map_controller.dart';

class EventMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventMapController>(
      () => EventMapController(),
    );
  }
}
