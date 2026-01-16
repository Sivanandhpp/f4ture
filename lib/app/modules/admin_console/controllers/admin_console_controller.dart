import 'package:f4ture/app/data/models/user_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:get/get.dart';

class AdminConsoleController extends GetxController {
  //TODO: Implement AdminConsoleController

  final AuthService _authService = AuthService.to;

  Rx<UserModel?> get currentUser => _authService.currentUser;

  Future<void> logout() async {
    await _authService.clearUser();
    Get.offAllNamed(Routes.AUTHENTICATION);
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
