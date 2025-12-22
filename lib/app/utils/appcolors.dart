import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  /// Background
  static Color get searchBackground =>
      _isDarkMode ? Color(0xFF1C1C1E) : Color(0xFFF9F9F9);
  static Color get background => _isDarkMode ? Color(0xFF000000) : Colors.white;

  /// Messages
  static Color get userMessage =>
      _isDarkMode ? Color(0xFF0A84FF) : Color(0xFF007AFF);
  static Color get contactMessage =>
      _isDarkMode ? Color(0xFF2C2C2E) : Color(0xFFE5E5EA);

  /// Actions
  static Color get primaryButton =>
      _isDarkMode ? Color(0xFF0A84FF) : Color(0xFF007AFF);
  static Color get unreadIndicator =>
      _isDarkMode ? Color(0xFF0A84FF) : Color(0xFF007AFF);

  /// Text
  static Color get textPrimary =>
      _isDarkMode ? Color(0xFFFFFFFF) : Color(0xFF333333);
  static Color get textSecondary =>
      _isDarkMode ? Color(0xFF8E8E93) : Color(0xFF666666);

  /// Icons
  static Color get iconNeutral =>
      _isDarkMode ? Color(0xFF8E8E93) : Color(0xFF8E8E93);
  static Color get iconNonNeutral =>
      _isDarkMode ? Colors.deepPurpleAccent.shade200 : Colors.deepPurpleAccent;
  static Color get chevron =>
      _isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

  /// Divider
  static Color get divider =>
      _isDarkMode ? Color(0xFF38383A) : Colors.grey.shade300;

  /// doesn't change
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  /// get theme

  static bool get _isDarkMode {
    // Utiliser Get pour détecter le thème actuel
    final context = Get.context;
    if (context == null) return false;

    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  //

  static Color dynamicColor({required Color light, required Color dark}) {
    return _isDarkMode ? dark : light;
  }
}
