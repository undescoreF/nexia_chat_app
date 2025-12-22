import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../chat/controller/chat_controller.dart';

class LanguageController extends GetxController {
  final storage = GetStorage();
  final RxString _selectedLanguage = 'en'.obs;

  String get selectedLanguage => _selectedLanguage.value;

  static const List<String> supportedLanguages = ['fr', 'ru', 'en'];

  @override
  void onInit() {
    super.onInit();
    final savedLanguage = storage.read('language');
    final deviceLanguage = Get.deviceLocale?.languageCode;

    if (savedLanguage != null && supportedLanguages.contains(savedLanguage)) {
      _selectedLanguage.value = savedLanguage;
    } else if (deviceLanguage != null &&
        supportedLanguages.contains(deviceLanguage)) {
      _selectedLanguage.value = deviceLanguage;
    } else {
      _selectedLanguage.value = 'en';
      storage.write('language', 'en');
    }
    updateLocale();
  }

  ///change language
  void changeLanguage(String languageCode) {
    if (!supportedLanguages.contains(languageCode)) {
      print('Langue non supportée: $languageCode');
      return;
    }

    _selectedLanguage.value = languageCode;
    storage.write('language', languageCode);
    updateLocale();
  }

  // Mettre à jour la locale de l'application avec validation
  void updateLocale() {
    Locale locale;
    final lang = _selectedLanguage.value;
    if (!supportedLanguages.contains(lang)) {
      _selectedLanguage.value = 'en';
      locale = const Locale('en', 'US');
      storage.write('language', 'en');
    } else {
      switch (lang) {
        case 'fr':
          locale = const Locale('fr', 'FR');
          break;
        case 'ru':
          locale = const Locale('ru', 'RU');
          break;
        case 'en':
        default:
          locale = const Locale('en', 'US');
          break;
      }
    }

    Get.updateLocale(locale);
    update();
  }

  String get currentLanguageName {
    switch (_selectedLanguage.value) {
      case 'fr':
        return 'Français';
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return 'English';
    }
  }

  String get currentFlagPath {
    switch (_selectedLanguage.value) {
      case 'fr':
        return "assets/images/flags/flag_fr.png";
      case 'ru':
        return "assets/images/flags/flag_ru.png";
      case 'en':
      default:
        return "assets/images/flags/flag_en.png";
    }
  }

  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }

  final List<Map<String, dynamic>> availableLanguages = [
    {
      'code': 'fr',
      'name': 'Français',
      'flag': 'assets/images/flags/flag_fr.png',
      'locale': const Locale('fr', 'FR'),
    },
    {
      'code': 'ru',
      'name': 'Русский',
      'flag': 'assets/images/flags/flag_ru.png',
      'locale': const Locale('ru', 'RU'),
    },
    {
      'code': 'en',
      'name': 'English',
      'flag': 'assets/images/flags/flag_en.png',
      'locale': const Locale('en', 'US'),
    },
  ];

  Locale getCurrentLocale() {
    switch (_selectedLanguage.value) {
      case 'fr':
        return const Locale('fr', 'FR');
      case 'ru':
        return const Locale('ru', 'RU');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  Language get currentLanguageEnum {
    switch (_selectedLanguage.value) {
      case 'fr':
        return Language.fr;
      case 'ru':
        return Language.ru;
      case 'en':
      default:
        return Language.en;
    }
  }
}
