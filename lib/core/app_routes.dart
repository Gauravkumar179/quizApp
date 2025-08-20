import 'package:get/get.dart';
import 'package:quizapp/views/main_screen.dart';
import '../views/login_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const quiz = '/quiz';

  static final pages = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: quiz, page: () => const MainScreen()),
  ];
}
