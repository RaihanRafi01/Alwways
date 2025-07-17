import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/authentication/verify_code_screen.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/authentication/signupWithOther.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CustomAppbar(title: 'forgot_password'.tr), // Use .tr for dynamic translation
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppLogo(),
              const SizedBox(height: 20),
              Text(
                "enter_email_to_reset".tr, // Use .tr for dynamic translation
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: "email".tr, // Use .tr for dynamic translation
                controller: emailController, // Pass controller to capture input
              ),
              const SizedBox(height: 16),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator() // Show loading indicator
                  : CustomButton(
                text: "continue".tr, // Use .tr for dynamic translation
                onPressed: () {
                  String email = emailController.text.trim();
                  if (email.isEmpty) {
                    Get.snackbar('warning'.tr, 'please_enter_email'.tr); // Use .tr for dynamic translation
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(email)) {
                    Get.snackbar('warning'.tr, 'please_enter_valid_email'.tr); // Use .tr for dynamic translation
                  } else {
                    authController.sendOtp(email); // Call sendOtp
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