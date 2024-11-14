import 'package:flutter/material.dart';

import '../../constants/color/app_colors.dart';

class PromptCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PromptCard({
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.bookBackground,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Tap to answer",
                style: TextStyle(fontSize: 14,color: AppColors.botTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
