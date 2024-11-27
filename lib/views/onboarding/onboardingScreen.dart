import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';  // Import gif package for GIF support
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {});
                },
                children: [
                  // Page 1 (with GIF)
                  _buildPage(
                    true,  // Add true to show GIF on this page
                    "assets/images/onboarding/onboarding_gif.gif",  // Path to your GIF
                    "Welcome to our app!",
                    "Discover amazing features tailored for you.",
                  ),
                  // Page 2
                  _buildPage(
                    false,  // Not showing GIF on other pages
                    "assets/images/onboarding/onboarding_2.png",
                    "Turn your answers into chapters",
                    " Chat with Titi, our AI, or answer the questionnaire to bring your memories to life.",
                  ),
                  // Page 3
                  _buildPage(
                    false,
                    "assets/images/onboarding/onboarding_3.png",
                    "Add images and customize",
                    " Make it unique: add photos and design a special cover.",
                  ),
                  // Page 4 - Final Page
                  _buildPage(
                    false,
                    "assets/images/onboarding/onboarding_4.png",
                    " Start for free and discover more",
                    "Create the first chapters for free and unlock the full book if you like it.",
                  ),
                ],
              ),
            ),
            // Dots Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 4, // Total number of pages
                effect: const WormEffect(
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  activeDotColor: AppColors.appColor,
                  dotColor: AppColors.dotInactive,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: CustomButton(
                text: 'Get Started',
                onPressed: () {
                  if (_pageController.page == 3) {
                    Get.offNamed(AppRoutes.login);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                backgroundColor: AppColors.borderColor,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a page widget with an optional GIF, SVG image, and two text widgets
  Widget _buildPage(bool showGif, String mediaPath, String text1, String text2) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // If it's the first page, display a GIF, else display an SVG or static image
          showGif
              ? Gif(image: AssetImage(mediaPath),
              autostart: Autostart.once,
          )
              : Image.asset(mediaPath, height: 390, width: 200),
      
          const SizedBox(height: 20),
          // First Text
          Text(
            text1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold,color: AppColors.appColor),
          ),
          const SizedBox(height: 10),
          // Second Text
          Text(
            text2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18,color: AppColors.onboardingText),
          ),
        ],
      ),
    );
  }
}
