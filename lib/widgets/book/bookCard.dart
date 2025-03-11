import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/views/subscription/cupon_view.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import '../../controllers/book/book_controller.dart';
import 'bookCover.dart';
import 'bookProgress.dart';

class BookCard extends StatelessWidget {
  final String title; // Added for dynamic book title
  final String coverImage; // Added for dynamic cover image
  final double progress;
  final bool isGrid;

  const BookCard({
    super.key,
    required this.title, // Required parameter for title
    required this.coverImage, // Required parameter for cover image
    required this.progress,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BookController());
    return Container(
      height: isGrid ? 270 : 450, // Set a flexible height for grid and non-grid views
      padding: EdgeInsets.all(isGrid ? 16 : 20),
      decoration: BoxDecoration(
        color: isGrid ? Colors.transparent : AppColors.bookBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isGrid ? Colors.transparent : AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flexible book cover widget with title and cover image
          Expanded(
            child: BookCover(
              isGrid: isGrid,
              isEdit: true,
              title: title, // Pass the title to BookCover
              coverImage: coverImage, // Pass the cover image to BookCover
            ),
          ),
          const SizedBox(height: 16),
          // Book progress bar widget
          BookProgressBar(progress: progress),
          const SizedBox(height: 16),
          // Conditional button if progress is 100%
          if (progress >= 1.0) // Check if progress is 100%
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 22,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(CouponView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Adjust the size to wrap the content
                    children: [
                      Icon(
                        Icons.file_download_outlined, // Replace with your preferred icon
                        size: 17, // Adjust the size of the icon
                        color: Colors.white, // Set the color of the icon
                      ),
                      SizedBox(width: 4), // Add some spacing between the icon and text
                      Text(
                        'Download Book',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white, // Set the text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}