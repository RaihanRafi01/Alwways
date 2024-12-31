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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //const SizedBox(height: 80),
              CustomTextField(
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                hint: 'Enter Email',
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description',
                controller: problemController,
                hint: 'Write Your Problem',
              ),
              const SizedBox(height: 40),
              Obx(() {
                return settingController.isLoading.value
                    ? const CircularProgressIndicator()
                    : CustomButton(
                  text: 'Send',
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
      _showSnackbar('Error', 'Please fill out all fields');
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackbar('Error', 'Please enter a valid email address');
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
