import 'package:get/get.dart';

class EventMapController extends GetxController {
  final RxInt selectedMapIndex = 0.obs;

  final List<Map<String, String>> maps = [
    {'title': 'Common', 'image': 'assets/images/common.jpg'},
    {'title': 'Campus', 'image': 'assets/images/campus.png'},
    {'title': 'Kinfra', 'image': 'assets/images/kinfra.jpg'},
  ];

  void changeMap(int index) {
    selectedMapIndex.value = index;
  }
}
