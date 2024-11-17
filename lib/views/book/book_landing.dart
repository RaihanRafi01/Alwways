import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import '../../widgets/customAppBar.dart';

class BookLandingScreen extends StatelessWidget {
  const BookLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: "All Books", isHome: true),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.7, // Adjust based on widget height
        ),
        itemCount: 5, // Define the number of items in the grid
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
    );
  }
}
