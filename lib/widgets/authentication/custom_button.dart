import 'package:flutter/material.dart';

import '../../constants/color/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isEditPage;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF8CAB91),
    this.borderColor = const Color(0xFF8CAB91),
    this.textColor = const Color(0xFFFAF1E6),
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
    this.isEditPage = false
  });

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: double.infinity, // Full-width button
      child: !isEditPage ? ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          textAlign: TextAlign.center,
          text.toUpperCase(),
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ) : OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor), // Border color
          backgroundColor: backgroundColor, // Background color
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            textAlign: TextAlign.center,
            text.toUpperCase(),
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      )
      ,
    );
  }
}
