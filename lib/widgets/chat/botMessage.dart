import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';

class BotMessage extends StatelessWidget {
  final String message;
  final List<Widget>? actions; // Existing parameter for actions (buttons)
  final bool isLoading; // Existing parameter for loading state
  final bool showNextChapterButton; // New parameter for chapter completion
  final VoidCallback? onNextChapterPressed; // New callback for next chapter button

  const BotMessage({
    super.key,
    required this.message,
    this.actions,
    this.isLoading = false,
    this.showNextChapterButton = false, // Default to false
    this.onNextChapterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 80.0, top: 16, bottom: 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? const ThreeDotsAnimation() // Show animation when loading
                : Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textColor,
              ),
            ),
            if (!isLoading) ...[
              // Show existing actions if provided
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: actions!,
                ),
              ],
              // Show next chapter button if showNextChapterButton is true
              if (showNextChapterButton) ...[
                const SizedBox(height: 8),
                CustomButton(text: 'proceed_to_next_chapter'.tr, onPressed: (){
                  onNextChapterPressed!();
                })
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// Separate widget for the three-dot animation (unchanged)
class ThreeDotsAnimation extends StatefulWidget {
  const ThreeDotsAnimation({super.key});

  @override
  _ThreeDotsAnimationState createState() => _ThreeDotsAnimationState();
}

class _ThreeDotsAnimationState extends State<ThreeDotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); // Repeat the animation
    _animation = IntTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        String dots = '.' * _animation.value; // Dynamically update dots
        return Text(
          '${"thinking".tr}$dots',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.botTextColor, // Match your bot text color
          ),
        );
      },
    );
  }
}