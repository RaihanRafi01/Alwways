import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import '../../controllers/book/book_controller.dart';
import 'bookCover.dart';
import 'bookProgress.dart';

class BookCard extends StatelessWidget {
  final double progress;
  final bool isGrid;

  const BookCard({
    super.key,
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
          // Flexible book cover widget
          Expanded(child: BookCover(isGrid: isGrid,isEdit: true,)),
          const SizedBox(height: 16),
          // Book progress bar widget
          BookProgressBar(progress: progress),
        ],
      ),
    );
  }
}