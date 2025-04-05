import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/controllers/home_controller.dart';
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
  final HomeController homeController = Get.put(HomeController());
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
                  title: "my_life".tr,
                  coverImage: '',
                  bookId: '',
                  isEpisode: false,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${"hi".tr} $name!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                    () => Text(
                  homeController.message.value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "TALK TO TITI",
                onPressed: () => Get.to(() => ChatLandingScreen()),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}