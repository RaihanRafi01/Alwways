import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('locale');

      print('LanguageController: Loading saved language settings');

      if (savedLocale != null) {
        final parts = savedLocale.split('_');
        if (parts.length == 2) {
          currentLocale.value = Locale(parts[0], parts[1]);
          Get.updateLocale(currentLocale.value);
          print('LanguageController: Loaded saved locale: $savedLocale');
          return;
        }
      }

      // If no saved locale, wait for LanguageInitializer to set it
      print('LanguageController: No saved locale found, relying on LanguageInitializer');
    } catch (e) {
      print('LanguageController: Error loading saved language - $e');
      currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(currentLocale.value);
    }
  }

  Future<void> changeLanguage(String languageCode, String countryCode) async {
    try {
      final newLocale = Locale(languageCode, countryCode);
      print('LanguageController: Changing language to $languageCode $countryCode');
      currentLocale.value = newLocale;
      Get.updateLocale(newLocale);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', '${languageCode}_$countryCode');

      // Update countryCode to maintain consistency
      String? newCountryCode;
      if (countryCode == 'ES') {
        newCountryCode = 'ES';
      } else if (countryCode == 'US' && prefs.getString('countryCode') == 'BD') {
        newCountryCode = 'BD';
      } else {
        newCountryCode = prefs.getString('countryCode') ?? 'DEFAULT';
      }
      await prefs.setString('countryCode', newCountryCode);

      print('LanguageController: Language updated successfully, countryCode set to $newCountryCode');
    } catch (e) {
      print('LanguageController: Error changing language - $e');
      currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(currentLocale.value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', 'en_US');
      await prefs.setString('countryCode', 'DEFAULT');
    }
  }
}