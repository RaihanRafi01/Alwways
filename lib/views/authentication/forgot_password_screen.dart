import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/authentication/signupWithOther.dart';
import '../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forget Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const AppLogo(),
            const SizedBox(height: 20),
            const Text("Enter your email to reset your password.",style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 16),
            const CustomTextField(label: "Email"),
            const SizedBox(height: 16,),
            CustomButton(text: "CONTINUE", onPressed: () => Get.toNamed('/language'),),
            const SizedBox(height: 16),
            const SignupWithOther(),
          ],
        ),
      ),
    );
  }
}
