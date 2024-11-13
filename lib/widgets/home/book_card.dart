import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class BookCard extends StatelessWidget {
  final double progress;

  const BookCard({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 408,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bookBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover with image background, title, and decoration
          Padding(
            padding: const EdgeInsets.only(left: 20.0,right: 20,top: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/images/book/cover_image_1.png",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Text and underline decoration
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "My Life",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SvgPicture.asset("assets/images/book/book_underline_1.svg"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Custom progress bar with rounded end only for the filled portion
          Stack(
            children: [
              // Background bar
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Foreground progress bar with rounded end
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
          // Progress text
          Text(
            '${(progress * 100).toInt()}% complete',
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}
