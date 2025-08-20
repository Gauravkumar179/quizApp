import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizapp/views/splash_screen.dart';
import 'core/firebase_initializer.dart';
import 'core/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quiz AI MVP/MVVM',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      getPages: AppRoutes.pages,
    );
  }
}
