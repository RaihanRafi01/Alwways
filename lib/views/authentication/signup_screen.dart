import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/authentication/profileImage.dart';
import 'package:playground_02/widgets/customAppBar.dart';

class SignupScreen extends StatelessWidget {
  final bool isEdit;
  final String title;

  const SignupScreen({super.key, this.isEdit = false, this.title = 'Create account'});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController dateController = TextEditingController(
      text: isEdit && authController.dateOfBirth.value != null
          ? DateFormat('dd/MM/yyyy').format(authController.dateOfBirth.value!)
          : '',
    );

    return Scaffold(
      appBar: CustomAppbar(title: title),
      body: Obx(() {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => ProfileImage(
                      pickedImage: authController.pickedImage.value,
                      profilePictureUrl: authController.profilePictureUrl.value,
                      onTap: authController.pickImage,
                    )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "First Name",
                            initialValue: isEdit ? authController.firstName.value : '',
                            onChanged: (value) => authController.firstName.value = value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: "Last Name",
                            initialValue: isEdit ? authController.lastName.value : '',
                            onChanged: (value) => authController.lastName.value = value,
                          ),
                        ),
                      ],
                    ),
                    if (!isEdit)
                    CustomTextField(
                      label: "Email address",
                      initialValue: isEdit ? authController.email.value : '',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      onChanged: (value) => authController.email.value = value,
                    ),
                    CustomTextField(
                      label: "Contact",
                      initialValue: isEdit ? authController.contact.value : '',
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => authController.contact.value = value,
                    ),
                    CustomTextField(
                      label: "Location",
                      initialValue: isEdit ? authController.location.value : '',
                      prefixIcon: Icons.location_on_outlined,
                      onChanged: (value) => authController.location.value = value,
                    ),
                    CustomTextField(
                      label: "Gender",
                      isDropdown: true,
                      dropdownItems: ['Male', 'Female', 'Other'],
                      initialValue: isEdit ? authController.gender.value : '',
                      onChanged: (value) => authController.gender.value = value,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.calendar_month_outlined,
                      label: "Date of Birth",
                      controller: dateController,
                      onTap: () async {
                        DateTime initialDate = isEdit && authController.dateOfBirth.value != null
                            ? authController.dateOfBirth.value!
                            : DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                          authController.dateOfBirth.value = pickedDate;
                        }
                      },
                    ),
                    if (!isEdit)
                    CustomTextField(
                      suffixIcon: Icons.visibility_off_outlined,
                      label: "Password",
                      isPassword: true,
                      onChanged: (value) => authController.password.value = value,
                    ),
                    if (!isEdit)
                      CustomTextField(
                        suffixIcon: Icons.visibility_off_outlined,
                        label: "Confirm Password",
                        isPassword: true,
                        onChanged: (value) => authController.confirmPassword.value = value,
                      ),
                    const SizedBox(height: 20),
                    if (isEdit)
                      CustomButton(
                        text: "Save Changes",
                        onPressed: () => authController.updateProfile(),
                      ),
                    if (!isEdit)
                      CustomButton(
                        text: "SIGN UP",
                        onPressed: () => authController.createAccount(),
                      ),
                    if (!isEdit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () => Get.toNamed('/login'),
                            child: const Text("Login"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (authController.isLoading.value)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }
}