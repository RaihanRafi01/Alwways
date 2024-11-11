import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/onboarding/splashScreen_2.dart'; // Import the second splash screen

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
      Get.to(() => const Splashscreen2()); // Navigate to the second splash screen
    });
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
