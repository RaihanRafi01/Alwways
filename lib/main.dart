import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/constants/translations/app_translations.dart';
import 'package:playground_02/constants/translations/language_controller.dart';

import 'constants/translations/language_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Main: App initialization started');
  await LanguageInitializer.initAppLanguage();
  print('Main: Language initialization completed');
  runApp(const MyApp());
  print('Main: App running');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp: Building app with locale: ${Get.locale}');
    return GetMaterialApp(
      title: 'Auth UI',
      translations: AppTranslations(),
      locale: Get.locale ?? const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppRoutes.splash1,
      getPages: AppRoutes.pages,
      theme: ThemeData(
        fontFamily: 'Visby',
      ),
    );
  }
}
