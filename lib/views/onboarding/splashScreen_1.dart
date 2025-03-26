import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import 'package:playground_02/views/home/home_landing.dart';
import 'package:playground_02/views/onboarding/onboardingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the second splash screen

class Splashscreen1 extends StatefulWidget {
  const Splashscreen1({super.key});

  @override
  State<Splashscreen1> createState() => _Splashscreen1State();
}

class _Splashscreen1State extends State<Splashscreen1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    // Get the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the 'isLoggedIn' value, default to false if not set
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Navigate based on login status
    if (isLoggedIn) {
      Get.offAll(const DashboardView()); // Navigate to home and clear stack
    } else {
      Get.offAll(const OnboardingScreen()); // Navigate to login and clear stack
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.appColor, // Set your desired background color here
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
}
