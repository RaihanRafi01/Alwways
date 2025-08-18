import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/book/book_landing.dart';
import 'package:playground_02/views/home/home_landing.dart';
import 'package:playground_02/views/profile/profile_landing.dart';
import '../../../constants/color/app_colors.dart';
import '../../../constants/translations/language_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/book/book_controller.dart';
import '../../../widgets/customNavigationBar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final int index;
  const DashboardView({super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.put(DashboardController());
    Get.put(BookController());
    final AuthController authController = Get.put(AuthController());
    authController.fetchProfile();
    Get.put(LanguageController());

    dashboardController.currentIndex.value = index;

    final List<Widget> _screens = [
      const HomePageLanding(),
      const BookLandingScreen(),
       ProfileScreen(),
    ];

    return Obx(() {
      if (authController.isProfileLoaded.value) {
        return Scaffold(
          backgroundColor: AppColors.appBackground,
          body: Stack(
            children: [
              SafeArea(
                child: Obx(() => _screens[dashboardController.currentIndex.value]),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: CustomNavigationBar(),
              ),
            ],
          ),
        );
      } else {
        // Show the same splash screen while loading
        return Scaffold(
          body: Container(
            color: AppColors.appColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo_white.png"),
                  const SizedBox(height: 8),
                  Image.asset("assets/images/app_name_white.png"),
                  const SizedBox(height: 16),
                  Text(
                    "app_name".tr,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }
}