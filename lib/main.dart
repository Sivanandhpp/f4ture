import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/index.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for persistent auth state
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AuthController as a permanent controller
  Get.put(AuthController(), permanent: true);

  runApp(
    GetMaterialApp(
      title: "F4ture",
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Initial route based on auth state
      initialRoute: AuthController.instance.isAuthenticated
          ? Routes.HOME
          : Routes.AUTHENTICATION,
      getPages: AppPages.routes,
    ),
  );
}
