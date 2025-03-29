import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/views/chatWithAI/chatLandingScreen.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/book/book_controller.dart';

class HomePageLanding extends StatefulWidget {
  const HomePageLanding({super.key});

  @override
  _HomePageLandingState createState() => _HomePageLandingState();
}

class _HomePageLandingState extends State<HomePageLanding> {
  final NavigationController navController = Get.put(NavigationController());
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    var name = authController.firstName.value;
    Get.put(BookController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: BookCover(
                  isGrid: false,
                  title: "my_life".tr, // Updated
                  coverImage: '',
                  bookId: '',
                  isEpisode: false,
                ),
              ),
              const SizedBox(height: 20),
               Text(
                '${"hi".tr} $name!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "thank_you_message".tr, // Updated
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              /*const SizedBox(height: 20),
              const Text(
                "welcome_message".tr, // Example for commented-out text
                style: TextStyle(color: AppColors.textColor, fontSize: 14),
              ),*/
              const SizedBox(height: 30), // Add a spacer to push buttons toward the center
              CustomButton(
                text: "talk_to_ai".tr, // Updated
                onPressed: () => Get.to(() => ChatLandingScreen()), //Get.toNamed(AppRoutes.chat),
              ),
              const SizedBox(height: 80),
              /*const SizedBox(height: 20),
              CustomButton(text: "STRUCTURED Q&A", onPressed: () {}),*/
              // Add another spacer to balance bottom space
            ],
          ),
        ),
      ),
      /*bottomNavigationBar: Obx(
            () => CustomBottomNavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onItemSelected: navController.changePage,
        ),
      ),*/
    );
  }
}