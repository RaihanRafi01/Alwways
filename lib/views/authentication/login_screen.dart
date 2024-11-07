import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/widgets/appLogo.dart';
import 'package:playground_02/widgets/custom_button.dart';
import 'package:playground_02/widgets/custom_textField.dart';
import 'package:playground_02/widgets/signupWithOther.dart';
import 'package:playground_02/widgets/social_button.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),),
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
                label: "Email",
                isPassword: false,
                onChanged: (value) => authController.email.value = value,
              ),
              CustomTextField(
                label: "Password",
                isPassword: true,
                onChanged: (value) => authController.password.value = value,
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  child: const Text("Forget Password", style: TextStyle(color: Colors.red,fontSize: 14,fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 10),

              // Login Button
              CustomButton(
                text: "LOG IN",
                onPressed: authController.login,
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

