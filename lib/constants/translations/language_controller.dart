import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  void changeLanguage(String languageCode, String countryCode) async {
    final newLocale = Locale(languageCode, countryCode);
    print('LanguageController: Changing language to $languageCode _ $countryCode');
    currentLocale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', '${languageCode}_$countryCode');
    print('LanguageController: Language updated successfully');
  }
}

class LanguageSelector extends StatelessWidget {
  final LanguageController languageController = Get.put(LanguageController());

  LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    print('LanguageSelector: Building with current locale: ${languageController.currentLocale.value}');
    return Obx(() => DropdownButton<Locale>(
      value: languageController.currentLocale.value,
      items: const [
        DropdownMenuItem(
          value: Locale('en', 'US'),
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: Locale('es', 'ES'),
          child: Text('Español'),
        ),
      ],
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          print('LanguageSelector: Language selection changed to ${newLocale.languageCode}_${newLocale.countryCode}');
          languageController.changeLanguage(
              newLocale.languageCode,
              newLocale.countryCode ?? '');
        }
      },
    ));
  }
}