/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/language_controller.dart';
import 'package:playground_02/widgets/authentication/LanguageOptionTile.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';

import '../../constants/translations/language_controller.dart';
class LanguageScreen extends StatelessWidget {
  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(),
              const SizedBox(height: 26),
              Text(
                "choose_language".tr,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Text(
                "chat_message".tr,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Obx(() {
                return Column(
                  children: [
                    LanguageOptionTile(
                      imagePath: 'assets/images/flags/flag_en.png',
                      languageName: "english".tr,
                      languageCode: 'en',
                      selectedLanguage: languageController.selectedLanguage.value,
                      onChanged: (value) => languageController.changeLanguage(value),
                    ),
                    LanguageOptionTile(
                      imagePath: 'assets/images/flags/flag_es.png',
                      languageName: "spanish".tr,
                      languageCode: 'es',
                      selectedLanguage: languageController.selectedLanguage.value,
                      onChanged: (value) => languageController.changeLanguage(value),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),
              CustomButton(
                text: "confirm".tr,
                onPressed: () {
                  languageController.saveLanguagePreference();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
