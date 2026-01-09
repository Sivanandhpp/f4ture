import 'package:get/get.dart';

class HomeController extends GetxController {
  // Current tab index for bottom navigation
  final currentIndex = 0.obs;

  // Change tab
  void changeTab(int index) {
    currentIndex.value = index;
  }
}
