import 'package:get/get.dart';

import '../controllers/manage_events_controller.dart';

class ManageEventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageEventsController>(() => ManageEventsController());
  }
}
