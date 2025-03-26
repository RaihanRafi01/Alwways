import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/views/authentication/forgot_password_screen.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/signupWithOther.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../widgets/authentication/custom_textField.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'login'.tr), // Use .tr for dynamic translation
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              const AppLogo(),

              const SizedBox(height: 20),

              // Email and Password Fields
              CustomTextField(
                label: "email".tr, // Use .tr for dynamic translation
                isPassword: false,
                onChanged: (value) => authController.email.value = value,
              ),
              CustomTextField(
                label: "password".tr, // Use .tr for dynamic translation
                isPassword: true,
                onChanged: (value) => authController.password.value = value,
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(ForgotPasswordScreen()),
                  child: Text("forgot_password".tr, style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)), // Use .tr for dynamic translation
                ),
              ),

              const SizedBox(height: 10),

              // Login Button
              CustomButton(
                text: "log_in".tr, // Use .tr for dynamic translation
                onPressed: () {
                  authController.login(authController.email.value, authController.password.value);
                },
                borderRadius: 20.0,
              ),

              const SizedBox(height: 10),

              // Sign-up link
              const SignupWithOther(),
            ],
          ),
        ),
      ),
    );
  }
}