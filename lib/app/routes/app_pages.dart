import 'package:f4ture/app/modules/chat/bindings/group_details_binding.dart';
import 'package:get/get.dart';

import '../modules/authentication/bindings/authentication_binding.dart';
import '../modules/authentication/views/authentication_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/controllers/group_details_controller.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/group_details_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/super_home/bindings/super_home_binding.dart';
import '../modules/super_home/views/super_home_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTHENTICATION;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATION,
      page: () => const AuthenticationView(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: _Paths.SUPER_HOME,
      page: () => const SuperHomeView(),
      binding: SuperHomeBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.GROUP_DETAILS,
      page: () => const GroupDetailsView(),
      binding: GroupDetailsBinding(),
    ),
  ];
}
