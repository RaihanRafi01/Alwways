import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/appLogo.dart';
import 'package:playground_02/widgets/custom_button.dart';
import 'package:playground_02/widgets/custom_textField.dart';
import 'package:playground_02/widgets/pinCode_InputField.dart';
import 'package:playground_02/widgets/signupWithOther.dart';
import '../../controllers/auth_controller.dart';

class VerifyCodeScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Code")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppLogo(),
              const SizedBox(height: 66),
              const Text("Enter Verification Code", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              PinCodeInputField(
                length: 4,
                onCompleted: (code) {
                  // Handle the completed code input
                  print("PIN code entered: $code");
                },
              ),
              const SizedBox(height: 16,),
              CustomButton(text: "VERIFY NOW", onPressed: () => Get.toNamed('/set-new-password'),),
              const SizedBox(height: 16),
              const SignupWithOther(),
            ],
          ),
        ),
      ),
    );
  }
}
