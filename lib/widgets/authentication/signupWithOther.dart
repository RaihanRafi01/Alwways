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
            child: Text("create_account".tr), // Use .tr for dynamic translation
          ),
          Text("or_sign_up_with".tr), // Use .tr for dynamic translation
        ],
      ),

      const SizedBox(height: 12),

      // Google and Apple Sign-in Buttons
      SocialButton(
        label: "log_in_with_google".tr, // Use .tr for dynamic translation
        iconPath: 'assets/images/auth/google_logo.png',
        onPressed: () {
          // Call Google sign-in function
        },
      ),
      const SizedBox(height: 8),
      SocialButton(
        label: "log_in_with_apple".tr, // Use .tr for dynamic translation
        iconPath: 'assets/images/auth/apple_logo.png',
        onPressed: () {
          // Call Apple sign-in function
        },
      ),
    ],);
  }
}