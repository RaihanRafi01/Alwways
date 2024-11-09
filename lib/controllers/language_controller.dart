import 'dart:ui';

import 'package:get/get.dart';

class LanguageController extends GetxController {
  var selectedLanguage = 'en'.obs; // Observable for language selection

  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode; // Update selected language
    // Update the app locale dynamically
    if (languageCode == 'en') {
      Get.updateLocale(const Locale('en', 'US'));
    } else if (languageCode == 'es') {
      Get.updateLocale(const Locale('es', 'ES'));
    }
  }

  void saveLanguagePreference() {
    // Optionally save the language to local storage for persistence
    // This could be used for remembering the user's language preference
  }
}
