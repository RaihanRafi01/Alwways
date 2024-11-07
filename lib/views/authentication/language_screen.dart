import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100), // Replace with your logo asset path
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your preferred language',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The AI will chat with you in the chosen language.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Obx(() => Column(
              children: [
                ListTile(
                  leading: Image.asset('assets/flags/us.png', width: 30), // English flag icon
                  title: const Text('English'),
                  trailing: Radio<String>(
                    value: 'en',
                    groupValue: languageController.selectedLanguage.value,
                    onChanged: (value) => languageController.changeLanguage(value!),
                  ),
                ),
                ListTile(
                  leading: Image.asset('assets/flags/es.png', width: 30), // Spanish flag icon
                  title: const Text('Español'),
                  trailing: Radio<String>(
                    value: 'es',
                    groupValue: languageController.selectedLanguage.value,
                    onChanged: (value) => languageController.changeLanguage(value!),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                languageController.saveLanguagePreference();
                Get.back();
              },
              child: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
