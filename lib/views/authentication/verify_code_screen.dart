import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/appLogo.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/pinCode_InputField.dart';
import 'package:playground_02/widgets/authentication/signupWithOther.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/auth_controller.dart';

class VerifyCodeScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final String email;
  late final String otp; // To store the OTP entered by the user

  VerifyCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CustomAppbar(title: "verify_code".tr), // Updated
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppLogo(),
              const SizedBox(height: 66),
              Text(
                "enter_verification_code".tr, // Updated
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              PinCodeInputField(
                length: 4,
                onCompleted: (code) {
                  otp = code; // Store the OTP when completed
                  print("PIN code entered: $otp");
                },
              ),
              const SizedBox(height: 16),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator() // Show loading indicator
                  : CustomButton(
                text: "verify_now".tr, // Updated
                onPressed: () {
                  if (otp.isEmpty || otp.length != 4) {
                    Get.snackbar(
                      "error".tr, // Updated
                      "please_enter_valid_otp".tr, // Updated
                    );
                  } else {
                    authController.verifyOtp(email, otp); // Call verifyOtp
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