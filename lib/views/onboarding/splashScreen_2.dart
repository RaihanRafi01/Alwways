import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/views/authentication/login_screen.dart'; // Import your login screen

class Splashscreen2 extends StatefulWidget {
  const Splashscreen2({super.key});

  @override
  State<Splashscreen2> createState() => _Splashscreen2State();
}

class _Splashscreen2State extends State<Splashscreen2> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => LoginScreen()); // Navigate to the login screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image without opacity
          Image.asset(
            "assets/images/onboarding_background.png", // Replace with your background image path
            fit: BoxFit.cover,
          ),
          // Background color with opacity
          Container(
            color: AppColors.appColor.withOpacity(0.71), // Set the background color with opacity
          ),
          // Centered content
          Center(
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
