import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/book/book_landing.dart';
import 'package:playground_02/views/home/home_landing.dart';
import 'package:playground_02/views/profile/profile_landing.dart';
import '../../../constants/color/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/book/book_controller.dart';
import '../../../widgets/customNavigationBar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final int index;
  const DashboardView({super.key,this.index = 0});

  @override
  Widget build(BuildContext context) {
    // Initialize the DashboardController
    final controller = Get.put(DashboardController());
    Get.put(BookController());
    final AuthController authController = Get.put(AuthController());
    authController.fetchProfile();

    controller.currentIndex.value = index;

    // List of pages for navigation
    final List<Widget> _screens = [
      const HomePageLanding(),
      const BookLandingScreen(),
       ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.appColor, // Set the background color
      body: Stack(
        children: [
          // The main content of the screen inside SafeArea to avoid overlap with bottom nav
          SafeArea(
            child: Obx(() => _screens[controller.currentIndex.value]),
          ),

          // The custom navigation bar at the bottom
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavigationBar(),
          ),
        ],
      ),
    );
  }
}
