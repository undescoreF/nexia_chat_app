import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../chat/controller/chat_controller.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();

  static const String _themeKey = 'app_theme';

  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    try {
      final savedTheme = _storage.read(_themeKey) ?? false;
      _isDarkMode.value = savedTheme;
      // }
    } catch (e) {
      debugPrint('Erreur lors du chargement du thème: $e');
      _isDarkMode.value = false;
    }
  }

  // Changer le thème
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _saveTheme();
    update();
  }

  void setTheme(bool isDark) {
    _isDarkMode.value = isDark;
    _saveTheme();
    update();
  }

  void setLightTheme() {
    _isDarkMode.value = false;
    _saveTheme();
    update();
  }

  void setDarkTheme() {
    _isDarkMode.value = true;
    _saveTheme();
    update();
  }

  void _saveTheme() {
    try {
      _storage.write(_themeKey, _isDarkMode.value);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
    }
  }

  IconData get themeIcon {
    return _isDarkMode.value ? Icons.light_mode : Icons.dark_mode;
  }

  String get themeText {
    return _isDarkMode.value ? 'Mode clair' : 'Mode sombre';
  }

  void resetToDefault() {
    _isDarkMode.value = false;
    _saveTheme();
    update();
  }

  void syncWithSystem(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkMode.value = (brightness == Brightness.dark);
    _saveTheme();
    update();
  }
}
