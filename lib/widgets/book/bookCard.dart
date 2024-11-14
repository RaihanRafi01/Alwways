import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/book/book_controller.dart';

class BookCard extends StatelessWidget {
  final double progress;
  final bool isGrid;

  const BookCard({
    Key? key,
    required this.progress,
    this.isGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
            Expanded(child: BookCover(isGrid: isGrid)),
            const SizedBox(height: 16),
            // Book progress bar widget
            BookProgressBar(progress: progress),
          ],
        ),
      ),
    );
  }
}


class BookCover extends StatelessWidget {
  final bool isGrid;

  const BookCover({
    Key? key,
    required this.isGrid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>(); // Find the controller

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            "assets/images/book/cover_image_1.png",
            height: isGrid ? 300 : 350,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text( // Reactive text display
              bookController.title.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox(height: 4),
            SvgPicture.asset("assets/images/book/book_underline_1.svg"),
          ],
        ),
      ],
    );
  }
}


class BookProgressBar extends StatelessWidget {
  final double progress;

  const BookProgressBar({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width * 0.7 * progress,
              decoration: BoxDecoration(
                color: AppColors.appColor,
                borderRadius: BorderRadius.horizontal(
                  left: const Radius.circular(10),
                  right: Radius.circular(progress == 1.0 ? 10 : 0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% complete',
          style: const TextStyle(
            color: AppColors.textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
