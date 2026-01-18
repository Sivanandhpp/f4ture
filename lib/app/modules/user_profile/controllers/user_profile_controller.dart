import 'package:f4ture/app/data/models/user_model.dart';
import 'package:f4ture/app/data/services/auth_service.dart';
import 'package:f4ture/app/routes/app_pages.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  //TODO: Implement UserProfileController

  final AuthService _authService = AuthService.to;

  Rx<UserModel?> get currentUser => _authService.currentUser;

  Future<void> logout() async {
    await _authService.clearUser();
    Get.offAllNamed(Routes.AUTHENTICATION);
  }

  void goToAbout() {
    Get.toNamed(Routes.ABOUT);
  }
}
