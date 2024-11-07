import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', height: 45.62, width: 52.8),
        const SizedBox(height: 10),
        Image.asset('assets/images/app_name.png', height: 24.24, width: 122),
        const SizedBox(height: 8),
        const Text(
          "una historia para siempre",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
