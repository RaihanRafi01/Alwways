import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/authentication/custom_button.dart';
import '../../../widgets/authentication/custom_textField.dart';
import '../controllers/setting_controller.dart';

class HelpSupportView extends GetView<SettingController> {
  HelpSupportView({super.key});

  final emailController = TextEditingController(); // Text controllers
  final problemController = TextEditingController();
  final SettingController settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // No title provided; add one if needed
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //const SizedBox(height: 80),
              CustomTextField(
                label: "email".tr, // Updated
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                hint: "enter_email".tr, // Updated
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "description".tr, // Updated
                controller: problemController,
                hint: "write_your_problem".tr, // Updated
              ),
              const SizedBox(height: 40),
              Obx(() {
                return settingController.isLoading.value
                    ? const CircularProgressIndicator()
                    : CustomButton(
                  text: "send".tr, // Updated
                  onPressed: _validateAndSend,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndSend() {
    final email = emailController.text.trim();
    final problem = problemController.text.trim();

    if (email.isEmpty || problem.isEmpty) {
      _showSnackbar("error".tr, "please_fill_out_all_fields".tr); // Updated
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackbar("error".tr, "please_enter_valid_email_address".tr); // Updated
      return;
    }

    //settingController.helpAndSupport(email, problem);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}