import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Use GetxService for a service that will be lazily loaded and persists
class ThemeService extends GetxService {
  final _box = GetStorage(); // Instance of GetStorage for local persistence
  final _key =
      'isDarkMode'; // A key to identify the theme preference in storage

  // A reactive variable to hold the dark mode state
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load the saved theme preference on initialization
    final savedValue = _box.read<bool>(_key);
    if (savedValue != null) {
      isDarkMode.value = savedValue;
    }
  }

  // A simple method to toggle the theme and save the new value
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write(_key, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Getter to provide the correct ThemeMode for the app
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
