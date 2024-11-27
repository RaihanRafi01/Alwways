import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import 'package:playground_02/widgets/home/book_card.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';

class BookOverView extends StatefulWidget {
  @override
  _HomePageLandingState createState() => _HomePageLandingState();
}

class _HomePageLandingState extends State<BookOverView> {
  final NavigationController navController = Get.put(NavigationController());
  final double progress = 0.3; // 30% completion progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 20,top: 30),
                  child: GestureDetector(
                    //TODO Change the route
                    onTap: () => Get.toNamed(AppRoutes.bookLanding),
                      child: BookCard(progress: progress)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hi Alex!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Thank you for sharing about your childhood. It’s a wonderful addition to your memoir. Let’s continue capturing these precious moments together.",
                  style: TextStyle(color: AppColors.textColor,fontSize: 14),),
                const SizedBox(height: 16),
                CustomButton(text: "TALK TO AI", onPressed: (){}),
                const SizedBox(height: 20),
                CustomButton(text: "STRUCTURED Q&A", onPressed: (){}),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: navController.selectedIndex.value,
        onItemSelected: navController.changePage,
      ),
    );
  }
}
