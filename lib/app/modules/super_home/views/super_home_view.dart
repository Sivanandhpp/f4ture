import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/super_home_controller.dart';
import '../../home/views/home_view.dart';
import 'tabs/chats_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/tasks_tab.dart';
import '../widgets/glass_floating_navbar.dart';

class SuperHomeView extends GetView<SuperHomeController> {
  const SuperHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Main Page Content
          Obx(
            () => IndexedStack(
              index: controller.tabIndex.value,
              children: const [
                HomeView(),
                ChatsTab(),
                TasksTab(),
                SettingsTab(),
              ],
            ),
          ),

          // 2. Floating Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => GlassFloatingNavbar(
                currentIndex: controller.tabIndex.value,
                onTap: controller.changeTab,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
