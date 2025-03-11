import 'package:get/get.dart';
import 'package:playground_02/views/authentication/forgot_password_screen.dart';
import 'package:playground_02/views/authentication/language_screen.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/authentication/set_new_password_screen.dart';
import 'package:playground_02/views/authentication/signup_screen.dart';
import 'package:playground_02/views/authentication/verify_code_screen.dart';
import 'package:playground_02/views/book/bookDetailsScreen.dart';
import 'package:playground_02/views/chatWithAI/chatScreen.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import 'package:playground_02/views/home/book_overview.dart';
import 'package:playground_02/views/home/home_landing.dart';
import 'package:playground_02/views/onboarding/onboardingScreen.dart';
import 'package:playground_02/views/onboarding/splashScreen_1.dart';

import '../views/book/addBook.dart';
import '../views/book/bookCoverEditScreen.dart';
import '../views/book/book_landing.dart';
import '../views/profile/profile_landing.dart';
class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String splash1 = '/splash1';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String setNewPassword = '/set-new-password';
  static const String signup = '/signup';
  static const String language = '/language';
  static const String homePageLanding = '/homePageLanding';
  static const String bookOverView = '/bookOverView';
  static const String bookLanding = '/bookLanding';
  static const String bookDetailsScreen = '/bookDetailsScreen';
  static const String bookAddScreen = '/bookAddScreen';
  static const String profileScreen = '/profileScreen';


  static const String chat = '/chat';

  static final List<GetPage> pages = [

    ///// ONBOARDING
    GetPage(name: splash1, page: () => const Splashscreen1()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: dashboard, page: () => const DashboardView()),

    ///// AUTH
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: language, page: () => LanguageScreen()),

    ///// HOME
    GetPage(name: homePageLanding, page: () => const HomePageLanding()),
    GetPage(name: bookOverView, page: () => BookOverView()),



    //// CHAT BOT

    GetPage(name: chat, page: () => const ChatScreen()),


    /////// BOOK

    GetPage(name: bookLanding, page: () => const BookLandingScreen()),
    GetPage(name: bookDetailsScreen, page: () => const BookDetailsScreen()),
    GetPage(name: bookLanding, page: () => const BookLandingScreen()),
    GetPage(name: bookAddScreen, page: () => const AddBook()),


    /////////////// PROFILE

    GetPage(name: profileScreen, page: () => ProfileScreen()),




  ];
}

class NavigationController extends GetxController {
  var selectedIndex = 0.obs; // Reactive variable for selected index

  // Method to update selected index and navigate
  void changePage(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        Get.toNamed(AppRoutes.homePageLanding);
        break;
      case 1:
        Get.toNamed(AppRoutes.bookLanding);
        break;
      case 2:
        Get.toNamed(AppRoutes.profileScreen);
        break;
      default:
        Get.toNamed(AppRoutes.homePageLanding);
    }
  }
}

