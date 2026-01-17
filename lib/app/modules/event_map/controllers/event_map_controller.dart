import 'package:get/get.dart';

class EventMapController extends GetxController {
  final RxInt selectedMapIndex = 0.obs;
  final RxBool isInteractingWithMap = false.obs;

  final List<Map<String, dynamic>> maps = [
    {
      'title': 'Common',
      'image': 'assets/images/common.png',
      'aspectRatio': 16 / 9,
    },
    {
      'title': 'Campus',
      'image': 'assets/images/campus.png',
      'aspectRatio': 1.0,
      'mapLink': 'https://maps.app.goo.gl/3kEkaFTCskauVEit6',
      'Address':
          'JAIN (Deemed-to-be University), Knowledge Park, Infopark, Kakkanad, Kochi',
      'locationImg': 'assets/images/campus_location.png',
    },
    {
      'title': 'Kinfra',
      'image': 'assets/images/kinfra.png',
      'aspectRatio': 1.0,
      'mapLink': 'https://maps.app.goo.gl/GMj73tK4M7ZQQrV69',
      'Address':
          'KINFRA International Exhibition cum Convention Centre, Infopark, Kakkanad, Kochi',
      'locationImg': 'assets/images/kinfra_location.png',
    },
  ];

  void changeMap(int index) {
    selectedMapIndex.value = index;
  }
}
