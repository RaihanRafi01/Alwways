import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/translations/language_controller.dart';

class SettingController extends GetxController {
  var isWritingReminderOn = false.obs;
  var selectedLanguage = 'English'.obs; // This will still track the UI selection
  var isLoading = false.obs;

  // Get the LanguageController instance
  final LanguageController languageController = Get.find<LanguageController>();

  // Toggle method for the Writing Reminder
  void toggleWritingReminder(bool value) {
    isWritingReminderOn.value = value;
  }

  // Change the language using LanguageController
  void changeLanguage(String newLanguage) {
    selectedLanguage.value = newLanguage; // Update the UI
    String languageCode;
    String countryCode;

    // Map the selected language to languageCode and countryCode
    switch (newLanguage) {
      case 'English':
        languageCode = 'en';
        countryCode = 'US';
        break;
      case 'Spanish':
        languageCode = 'es';
        countryCode = 'ES';
        break;
    /*case 'French':
        languageCode = 'fr';
        countryCode = 'FR';
        break;*/
      default:
        languageCode = 'en';
        countryCode = 'US';
    }

    // Call the LanguageController's changeLanguage method
    languageController.changeLanguage(languageCode, countryCode);
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage(); // Load the saved language on initialization
  }

  // Load the saved language from SharedPreferences
  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale') ?? 'en_US';
    final parts = savedLocale.split('_');
    String languageCode = parts[0];
    String countryCode = parts[1];

    // Update the selectedLanguage based on saved locale
    if (languageCode == 'en' && countryCode == 'US') {
      selectedLanguage.value = 'English';
    } else if (languageCode == 'es' && countryCode == 'ES') {
      selectedLanguage.value = 'Spanish';
    } /*else if (languageCode == 'fr' && countryCode == 'FR') {
      selectedLanguage.value = 'French';
    }*/

    // Sync the LanguageController's currentLocale
    languageController.currentLocale.value = Locale(languageCode, countryCode);
  }
}