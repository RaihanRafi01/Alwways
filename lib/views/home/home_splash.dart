import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import 'package:playground_02/views/onboarding/onboardingScreen.dart'; // Import the second splash screen

class HomeSplashscreen extends StatefulWidget {
  const HomeSplashscreen({super.key});

  @override
  State<HomeSplashscreen> createState() => _HomeSplashscreenState();
}

class _HomeSplashscreenState extends State<HomeSplashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(const DashboardView());// Navigate to the second splash screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/home/home_splash.png'),
            const SizedBox(height: 16),
            const Text('Welcome To our Family',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w400),)
          ],
        ),
      ),
    );
  }
}
