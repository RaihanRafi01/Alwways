import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class BotMessage extends StatelessWidget {
  final String message;
  final List<Widget>? actions; // Existing parameter for actions (buttons)
  final bool isLoading; // New parameter for loading state

  const BotMessage({
    super.key,
    required this.message,
    this.actions,
    this.isLoading = false, // Default to false
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
                fontSize: 16,
                color: AppColors.botTextColor,
              ),
            ),
            if (!isLoading && actions != null && actions!.isNotEmpty) ...[
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

// Separate widget for the three-dot animation
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
          'Thinking$dots',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.botTextColor, // Match your bot text color
          ),
        );
      },
    );
  }
}