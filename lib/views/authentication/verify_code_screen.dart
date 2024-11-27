import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/pinCode_InputField.dart';
import 'package:playground_02/widgets/authentication/signupWithOther.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../controllers/auth_controller.dart';

class VerifyCodeScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Verify Code'),
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
              CustomButton(text: "VERIFY NOW", onPressed: () => Get.offAllNamed('/set-new-password'),),
              const SizedBox(height: 16),
              const SignupWithOther(),
            ],
          ),
        ),
      ),
    );
  }
}
