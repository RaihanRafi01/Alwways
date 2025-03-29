import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import 'package:playground_02/views/home/home_landing.dart';
import 'package:playground_02/views/onboarding/onboardingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';

class Splashscreen1 extends StatefulWidget {
  const Splashscreen1({super.key});

  @override
  State<Splashscreen1> createState() => _Splashscreen1State();
}

class _Splashscreen1State extends State<Splashscreen1> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Get the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the 'isLoggedIn' value, default to false if not set
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });

    // Navigate based on login status after a small delay to show splash screen
    if (isLoggedIn) {
      // Immediately navigate to dashboard if logged in
      Get.offAll(const DashboardView());
    } else {
      // Show splash for 2 seconds only for onboarding
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(const OnboardingScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
    } else {
      return const Scaffold();
    }
  }
}