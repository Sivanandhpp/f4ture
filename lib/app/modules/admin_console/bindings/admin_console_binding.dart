import 'package:get/get.dart';

import '../../super_home/controllers/global_tasks_controller.dart';
import '../controllers/admin_console_controller.dart';

class AdminConsoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminConsoleController>(() => AdminConsoleController());
    Get.lazyPut<GlobalTasksController>(() => GlobalTasksController());
  }
}
