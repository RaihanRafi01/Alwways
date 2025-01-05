import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';
import '../../widgets/book/bookPageView.dart';
import '../../widgets/customAppBar.dart';

class BookLandingScreen extends StatefulWidget {
  final int bookNumber; // Updated variable naming for better readability
  final bool isEpisode; // Determines if we are showing episodes instead of books
  const BookLandingScreen({super.key, this.bookNumber = 3, this.isEpisode = false});

  @override
  State<BookLandingScreen> createState() => _BookLandingScreenState();
}

class _BookLandingScreenState extends State<BookLandingScreen> {
  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: widget.isEpisode ? "Episodes" : "All Books",
        isHome: !widget.isEpisode, // Show the home icon only for "All Books"
      ),
      body: Stack(
        children: [
          // GridView for books or episodes
          GridView.builder(
            padding: const EdgeInsets.only(bottom: 95),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              childAspectRatio: 0.55, // Adjust based on widget height
            ),
            itemCount: widget.bookNumber,
            itemBuilder: (context, index) {
              double progress = (index + 1) / 3; // Simulated progress for books/episodes
              return GestureDetector(
                onTap: () {
                  // Handle navigation logic based on the current screen type
                  if (widget.isEpisode) {
                    // Navigate to the BookDetailsScreen when on the episodes screen
                    Get.to(BookPageView(), arguments: {"episodeIndex": index});   // bookDetailsScreen
                  } else {
                    // Navigate to the episodes screen when on the books screen
                    Get.to(
                      BookLandingScreen(bookNumber: 6, isEpisode: true),
                    );
                  }
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
                height: 50,
                width: 50,
              ),
            ),
          ),
        ],
      ),
      // Bottom navigation bar (commented initially, uncomment if needed)
      /*bottomNavigationBar: Obx(
        () => CustomBottomNavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onItemSelected: navController.changePage,
        ),
      ),*/
    );
  }
}
