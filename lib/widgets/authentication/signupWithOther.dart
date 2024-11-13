import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/social_button.dart';
class SignupWithOther extends StatelessWidget {
  const SignupWithOther({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Get.toNamed('/signup'),
            child: const Text("Create an account"),
          ),
          const Text("or sign up with "),
        ],
      ),

      const SizedBox(height: 12),

      // Google and Apple Sign-in Buttons
      SocialButton(
        label: "Log in with Google",
        iconPath: 'assets/images/auth/google_logo.png',
        onPressed: () {
          // Call Google sign-in function
        },
      ),
      const SizedBox(height: 8),
      SocialButton(
        label: "Log in with Apple",
        iconPath: 'assets/images/auth/apple_logo.png',
        onPressed: () {
          // Call Apple sign-in function
        },
      ),
    ],);
  }
}
