import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/appLogo.dart';
import 'package:playground_02/widgets/custom_button.dart';
import 'package:playground_02/widgets/custom_textField.dart';
import 'package:playground_02/widgets/signupWithOther.dart';
import '../../controllers/auth_controller.dart';

class SetNewPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set New Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const AppLogo(),
                const SizedBox(height: 60),
                const CustomTextField(label: "New Password" , suffixIcon : Icons.visibility_off_outlined,isPassword: true,),
                const CustomTextField(label: "Confirm Password", suffixIcon : Icons.visibility_off_outlined,isPassword: true,),
                const SizedBox(height: 16,),
                // TODO
                // After provide the new password ; next page will be ?
                CustomButton(text: "SUBMIT", onPressed: () => Get.toNamed('/login'),),
                const SizedBox(height: 16),
                const SignupWithOther(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
