import 'package:f4ture/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../controllers/super_home_controller.dart';

class SuperHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperHomeController>(
      () => SuperHomeController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
