import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:get/get.dart';

class AppLogo extends StatelessWidget {
  final bool splash;
  const AppLogo({super.key, this.splash = false});

  @override
  Widget build(BuildContext context) {
    return splash
        ? Scaffold(
      body: Center( // Center the entire container on the screen
        child: Container(
          width: 301, // Fixed width
          height: 171, // Fixed height
          padding: const EdgeInsets.all(8.0), // Padding inside the container
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo image with fixed size
              SizedBox(
                width: double.infinity, // Full width of the container
                height: 60, // Adjust the height of the logo image
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10), // Space between images
              // App name image with fixed size
              SizedBox(
                width: double.infinity, // Full width of the container
                height: 50, // Adjust the height of the app name image
                child: Image.asset(
                  'assets/images/app_name.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10), // Space between images and text
              // Text for app name with dynamic font size
              Text(
                "app_name".tr, // This will be translated based on locale
                style: const TextStyle(
                  fontSize: 14, // Set a fixed font size
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center, // Ensure text is centered
              ),
            ],
          ),
        ),
      ),
    )
        : Column(
      children: [
        Image.asset('assets/images/logo.png', height: 45.62, width: 52.8),
        const SizedBox(height: 10),
        Image.asset('assets/images/app_name.png', height: 24.24, width: 122),
        const SizedBox(height: 8),
        Text(
          "app_name".tr, // This will be translated based on locale
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
