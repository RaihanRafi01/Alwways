import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/authentication/forgot_password_screen.dart';
import 'views/authentication/login_screen.dart';
import 'views/authentication/set_new_password_screen.dart';
import 'views/authentication/verify_code_screen.dart';
import 'views/authentication/signup_screen.dart';
import 'views/authentication/language_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth UI',
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordScreen()),
        GetPage(name: '/verify-code', page: () => VerifyCodeScreen()),
        GetPage(name: '/set-new-password', page: () => SetNewPasswordScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/language', page: () => LanguageScreen()),
      ],
    );
  }
}
