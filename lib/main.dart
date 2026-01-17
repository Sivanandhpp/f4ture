import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

import 'package:get_storage/get_storage.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/local_chat_service.dart';

// Global Route Observer
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await Get.putAsync(
    () => NotificationService().init().then((_) => NotificationService()),
  ); // Register NotificationService
  Get.put(LocalChatService());
  final authService = Get.put(AuthService());

  runApp(
    GetMaterialApp(
      title: "F4ture",
      initialRoute: authService.determineInitialRoute(),
      getPages: AppPages.routes,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        scaffoldBackgroundColor: AppColors.scaffoldbg,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
    ),
  );
}
