import 'package:get/get.dart';

import '../modules/attendee/bindings/attendee_binding.dart';
import '../modules/attendee/views/attendee_view.dart';
import '../modules/authentication/bindings/authentication_binding.dart';
import '../modules/authentication/bindings/user_details_binding.dart';
import '../modules/authentication/views/authentication_view.dart';
import '../modules/authentication/views/user_details_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/bindings/group_details_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/group_details_view.dart';
import '../modules/create_event/bindings/create_event_binding.dart';
import '../modules/create_event/bindings/manage_events_binding.dart';
import '../modules/create_event/views/create_event_view.dart';
import '../modules/create_event/views/manage_events_view.dart';
import '../modules/event_map/bindings/event_map_binding.dart';
import '../modules/event_map/views/event_map_view.dart';
import '../modules/event_schedule/bindings/event_schedule_binding.dart';
import '../modules/event_schedule/views/event_schedule_view.dart';
import '../modules/feed/bindings/feed_binding.dart';
import '../modules/feed/views/feed_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/manage_users/bindings/manage_users_binding.dart';
import '../modules/manage_users/views/manage_users_view.dart';
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
      name: _Paths.USER_DETAILS,
      page: () => const UserDetailsView(),
      binding: UserDetailsBinding(),
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
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_EVENT,
      page: () => const CreateEventView(),
      binding: CreateEventBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_EVENTS,
      page: () => const ManageEventsView(),
      binding: ManageEventsBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_USERS,
      page: () => const ManageUsersView(),
      binding: ManageUsersBinding(),
    ),
    GetPage(
      name: _Paths.ATTENDEE,
      page: () => const AttendeeView(),
      binding: AttendeeBinding(),
    ),
    GetPage(
      name: _Paths.FEED,
      page: () => const FeedView(),
      binding: FeedBinding(),
    ),
    GetPage(
      name: _Paths.EVENT_SCHEDULE,
      page: () => const EventScheduleView(),
      binding: EventScheduleBinding(),
    ),
    GetPage(
      name: _Paths.EVENT_MAP,
      page: () => const EventMapView(),
      binding: EventMapBinding(),
    ),
  ];
}
