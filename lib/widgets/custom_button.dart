import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF8CAB91),
    this.textColor = const Color(0xFFFAF1E6),
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full-width button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }
}
