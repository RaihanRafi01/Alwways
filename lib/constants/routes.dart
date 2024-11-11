import 'package:get/get.dart';
import 'package:playground_02/views/authentication/forgot_password_screen.dart';
import 'package:playground_02/views/authentication/language_screen.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/authentication/set_new_password_screen.dart';
import 'package:playground_02/views/authentication/signup_screen.dart';
import 'package:playground_02/views/authentication/verify_code_screen.dart';
import 'package:playground_02/views/chatWithAI/chatScreen.dart';
import 'package:playground_02/views/onboarding/splashScreen_1.dart';
class AppRoutes {
  static const String splash1 = '/splash1';
  static const String splash2 = '/splash2';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String setNewPassword = '/set-new-password';
  static const String signup = '/signup';
  static const String language = '/language';


  static const String chat = '/chat';

  static final List<GetPage> pages = [
    GetPage(name: splash1, page: () => const Splashscreen1()),
    GetPage(name: splash2, page: () => LoginScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: verifyCode, page: () => VerifyCodeScreen()),
    GetPage(name: setNewPassword, page: () => SetNewPasswordScreen()),
    GetPage(name: signup, page: () => SignupScreen()),
    GetPage(name: language, page: () => LanguageScreen()),


    GetPage(name: chat, page: () => ChatScreen()),
  ];
}
