import 'package:get/get.dart';

import '../controllers/super_home_controller.dart';

class SuperHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperHomeController>(
      () => SuperHomeController(),
    );
  }
}
