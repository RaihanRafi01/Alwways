import 'package:flutter/material.dart';

import '../../constants/color/app_colors.dart';

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
              width: MediaQuery.of(context).size.width * 0.4 * progress,
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