import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Import flutter_svg
import 'package:playground_02/constants/color/app_colors.dart';

class BookPreview extends StatelessWidget {
  final String bookTitle;
  final String svgPath;

  const BookPreview({super.key, required this.bookTitle, required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.bookBackground2,AppColors.bookBackground1]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Book cover image
              Image.asset(
                'assets/images/chat/book_cover.png', // Ensure this asset exists
                height: 350,
              ),
              // Centered Column with book title and underline
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures only the needed space is used
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Book title with a fixed width
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Transform.rotate(
                        angle: 0.3,
                        child: SizedBox(
                          width: 130, // Set a fixed width for the text (adjust as needed)
                          child: Text(
                            bookTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.clip, // Ensures text does not overflow
                            textAlign: TextAlign.center, // Centers the text horizontally
                          ),
                        ),
                      ),
                    ),
                    // SVG underline
                    SvgPicture.asset(
                      svgPath, // Use the dynamic SVG path
                      height: 50, // Adjust the size as needed
                      width: 50,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
