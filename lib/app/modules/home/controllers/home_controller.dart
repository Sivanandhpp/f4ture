import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/modules/super_home/controllers/super_home_controller.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();
  final isVideoVisible = true.obs;

  late SuperHomeController _superHomeController;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Safely find SuperHomeController
    try {
      _superHomeController = Get.find<SuperHomeController>();

      // Listen to tab changes
      ever(_superHomeController.tabIndex, (_) => _checkVisibility());
    } catch (e) {
      debugPrint('SuperHomeController not found: $e');
    }

    // Listen to scroll changes
    scrollController.addListener(_checkVisibility);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    _checkVisibility();
  }

  void _checkVisibility() {
    // 1. Check App Lifecycle
    if (_appLifecycleState != AppLifecycleState.resumed) {
      if (isVideoVisible.value) isVideoVisible.value = false;
      return;
    }

    // 2. Check Tab Index (If SuperHome is present)
    // Note: We access .value directly. If _superHomeController isn't found, we skip this check (assume visible if standalone).
    try {
      if (_superHomeController.tabIndex.value != 0) {
        if (isVideoVisible.value) isVideoVisible.value = false;
        return;
      }
    } catch (_) {}

    // 3. Check Scroll Position
    // If scrolled down more than half screen height, pause.
    if (scrollController.hasClients &&
        scrollController.offset > Get.height * 0.5) {
      if (isVideoVisible.value) isVideoVisible.value = false;
      return;
    }

    // If all checks pass, play video
    if (!isVideoVisible.value) isVideoVisible.value = true;
  }
}
