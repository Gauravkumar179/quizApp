import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quizapp/views/splash_screen.dart';
import 'package:quizapp/views/theme_service.dart';
import 'core/firebase_initializer.dart';
import 'core/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage before running the app
  await GetStorage.init();
  await FirebaseInitializer.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the ThemeService into memory so it's available globally
    final themeService = Get.put<ThemeService>(ThemeService());

    // Use Obx to make GetMaterialApp reactive to theme changes
    return Obx(
      () => GetMaterialApp(
        title: 'Quiz AI MVP/MVVM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(), // Define your light theme
        darkTheme: ThemeData.dark(), // Define your dark theme
        themeMode: themeService
            .themeMode, // Get the current theme mode from the service
        home: const SplashScreen(),
        getPages: AppRoutes.pages,
      ),
    );
  }
}
