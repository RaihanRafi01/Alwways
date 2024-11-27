import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';

class HomePageLanding extends StatefulWidget {
  const HomePageLanding({super.key});

  @override
  _HomePageLandingState createState() => _HomePageLandingState();
}

class _HomePageLandingState extends State<HomePageLanding> {
  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Hi Alex!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Start Your life story writing Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome to your personalized life story-writing experience. Choose how you would like to start documenting your life stories. You can engage in a real-time conversation with the AI for a dynamic storytelling experience or select the structured Q&A mode for a guided approach. Both options will help you create meaningful chapters about your life.",
                style: TextStyle(color: AppColors.textColor, fontSize: 14),
              ),
              const SizedBox(height: 30), // Add a spacer to push buttons toward the center
              CustomButton(
                text: "TALK TO AI",
                onPressed: () => Get.toNamed(AppRoutes.chat),
              ),
              const SizedBox(height: 20),
              CustomButton(text: "STRUCTURED Q&A", onPressed: () {}),
              // Add another spacer to balance bottom space
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
            () => CustomBottomNavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onItemSelected: navController.changePage,
        ),
      ),
    );
  }
}

