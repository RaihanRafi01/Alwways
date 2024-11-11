import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/constants/translations/app_translations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth UI',
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppRoutes.chat,
      getPages: AppRoutes.pages,
      theme: ThemeData(
        fontFamily: 'Visby',
      ),
    );
  }
}
