import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class BotMessage extends StatelessWidget {
  final String message;
  final List<Widget>? actions; // New parameter for actions (buttons)

  const BotMessage({super.key, required this.message, this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 80.0, top: 16, bottom: 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.botTextColor,
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
