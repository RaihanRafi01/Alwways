import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/authentication/signupWithOther.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../controllers/auth_controller.dart';

class SetNewPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController()); // Use Get.find instead of Get.put
  final String email;
  final String otp;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  SetNewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Set New Password'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppLogo(),
              const SizedBox(height: 60),
              CustomTextField(
                label: "New Password",
                suffixIcon: Icons.visibility_off_outlined,
                isPassword: true,
                controller: newPasswordController, // Capture new password
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Confirm Password",
                suffixIcon: Icons.visibility_off_outlined,
                isPassword: true,
                controller: confirmPasswordController, // Capture confirm password
              ),
              const SizedBox(height: 16),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator() // Show loading indicator
                  : CustomButton(
                text: "SUBMIT",
                onPressed: () {
                  String newPassword = newPasswordController.text.trim();
                  String confirmPassword = confirmPasswordController.text.trim();

                  // Local validation
                  if (newPassword.isEmpty || confirmPassword.isEmpty) {
                    Get.snackbar('Error', 'Please fill in both fields');
                  } else if (newPassword != confirmPassword) {
                    Get.snackbar('Error', 'Passwords do not match');
                  } else if (newPassword.length < 6) {
                    Get.snackbar('Error', 'Password must be at least 6 characters');
                  } else {
                    authController.resetPassword(email, otp, newPassword); // Call resetPassword
                  }
                },
              )),
              const SizedBox(height: 16),
              const SignupWithOther(),
            ],
          ),
        ),
      ),
    );
  }
}