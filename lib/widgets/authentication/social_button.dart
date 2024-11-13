import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.label,
    required this.iconPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 221,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(iconPath, height: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: const BorderSide(color: AppColors.buttonBorderColor, width: 2),
        ),
      ),
    );
  }
}
