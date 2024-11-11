import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class BookPreview extends StatelessWidget {
  const BookPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.chatTextBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/chat/book_cover.png', // Make sure to add this asset
                height: 150,
              ),
              const SizedBox(height: 10),
              const Text(
                "Here's A First look at your book. Tap to open it",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}