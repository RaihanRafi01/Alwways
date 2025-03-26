import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/color/app_colors.dart';

class BookProgressBar extends StatelessWidget {
  final double progress;

  const BookProgressBar({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug the input value
    print('Progress value received: $progress');

    // Normalize progress from percentage (0-100) to fraction (0.0-1.0)
    final normalizedProgress = (progress / 100).clamp(0.0, 1.0);
    final percentage = progress.toInt(); // Use raw progress as percentage

    // Debug the calculated values
    print('Normalized progress: $normalizedProgress');
    print('Displayed percentage: $percentage');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 10,
                  width: constraints.maxWidth, // Full width of parent
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  height: 10,
                  width: constraints.maxWidth * normalizedProgress, // Scale with normalized progress
                  decoration: BoxDecoration(
                    color: AppColors.appColor,
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(10),
                      right: Radius.circular(normalizedProgress == 1.0 ? 10 : 0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% ${"complete".tr}',
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}