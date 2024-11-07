import 'dart:ui';

import 'package:get/get.dart';

class LanguageController extends GetxController {
  var selectedLanguage = 'en'.obs;

  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    // Optionally, set the app language here
    if (languageCode == 'en') {
      Get.updateLocale(const Locale('en', 'US'));
    } else if (languageCode == 'es') {
      Get.updateLocale(const Locale('es', 'ES'));
    }
  }

  void saveLanguagePreference() {
    // Save the selected language to local storage or shared preferences
    // This can be used to persist language choice
  }
}
