import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';
import '../../widgets/customAppBar.dart';

class BookLandingScreen extends StatefulWidget {
  const BookLandingScreen({super.key});

  @override
  State<BookLandingScreen> createState() => _BookLandingScreenState();
}

class _BookLandingScreenState extends State<BookLandingScreen> {
  final NavigationController navController = Get.put(NavigationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "All Books", isHome: true, ),
      body: Stack(
        children: [
          // GridView for the books
          GridView.builder(
            padding: const EdgeInsets.only(bottom: 95), // Add padding around the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              childAspectRatio: 0.55, // Adjust based on widget height
            ),
            itemCount: 8, // Define the number of items in the grid
            itemBuilder: (context, index) {
              double progress = (index + 1) / 6; // Set different progress for each book
              return GestureDetector(
                onTap: () {
                  // Use GetX to navigate to the BookDetailsScreen, passing the bookIndex as a parameter
                  Get.toNamed(AppRoutes.bookDetailsScreen);
                },
                child: BookCard(progress: progress, isGrid: true),
              );
            },
          ),

          // Floating SVG Button
          Positioned(
            bottom: 60,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.bookAddScreen);
                print('Floating button clicked!');
              },
              child: SvgPicture.asset(
                'assets/images/book/add_icon.svg', // Replace with the path to your SVG file
                height: 50, // Set the size of the button
                width: 50,
              ),
            ),
          ),
        ],
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
