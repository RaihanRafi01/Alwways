/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/widgets/chat/promptCard.dart';

class PromptBottomSheet extends StatelessWidget {
  const PromptBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController messageController = Get.find<MessageController>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cross icon at the top-right corner
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset("assets/images/chat/cancel_icon_green.svg"),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // List of PromptCards
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Set the number of items as needed
              itemBuilder: (context, index) {
                return PromptCard(
                  title: 'Title $index',
                  onTap: () {
                    messageController.sendBotMessage('You selected prompt $index');
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          // Button at the bottom
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: () {
                messageController.sendBotMessage('Here are some new prompts!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: const BorderSide(
                  color: AppColors.botTextColor,
                  width: 2,
                ),
              ),
              child: const Text(
                'Give me new prompts',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.botTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
