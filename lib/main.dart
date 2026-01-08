import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/index.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "F4ture",
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Follows device settings

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
