import 'package:get/get.dart';

import 'package:f4ture/app/modules/chat/controllers/chat_controller.dart';
import 'package:f4ture/app/modules/chat/controllers/group_issues_controller.dart';
import 'package:f4ture/app/modules/chat/controllers/group_tasks_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<GroupTasksController>(() => GroupTasksController());
    Get.lazyPut<GroupIssuesController>(() => GroupIssuesController());
  }
}
