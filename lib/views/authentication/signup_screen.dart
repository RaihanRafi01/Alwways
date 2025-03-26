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
  final String? title;

  SignupScreen({super.key, this.isEdit = false, this.title}); // Default title uses translation

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController is available
    final AuthController authController = Get.put(AuthController());

    // Pre-fill dateController with the existing date of birth
    final TextEditingController dateController = TextEditingController(
      text: authController.dateOfBirth.value != null
          ? DateFormat('dd/MM/yyyy').format(authController.dateOfBirth.value!)
          : '',
    );

    // Pre-fill other fields with controllers to ensure two-way binding
    final TextEditingController firstNameController = TextEditingController(
      text: authController.firstName.value,
    );
    final TextEditingController lastNameController = TextEditingController(
      text: authController.lastName.value,
    );
    final TextEditingController emailController = TextEditingController(
      text: authController.email.value,
    );
    final TextEditingController contactController = TextEditingController(
      text: authController.contact.value,
    );
    final TextEditingController locationController = TextEditingController(
      text: authController.location.value,
    );
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: CustomAppbar(title: title!),
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
                            label: "first_name".tr, // Use .tr for dynamic translation
                            controller: firstNameController,
                            onChanged: (value) => authController.firstName.value = value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: "last_name".tr, // Use .tr for dynamic translation
                            controller: lastNameController,
                            onChanged: (value) => authController.lastName.value = value,
                          ),
                        ),
                      ],
                    ),
                    if (!isEdit)
                      CustomTextField(
                        label: "email_address".tr, // Use .tr for dynamic translation
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        onChanged: (value) => authController.email.value = value,
                      ),
                    CustomTextField(
                      label: "contact".tr, // Use .tr for dynamic translation
                      controller: contactController,
                      phone: true, // Use IntlPhoneField for consistency
                      initialValue: authController.contact.value, // Pre-fill phone number
                      onChanged: (value) => authController.contact.value = value,
                    ),
                    CustomTextField(
                      label: "location".tr, // Use .tr for dynamic translation
                      controller: locationController,
                      prefixIcon: Icons.location_on_outlined,
                      onChanged: (value) => authController.location.value = value,
                    ),
                    CustomTextField(
                      label: "gender".tr, // Use .tr for dynamic translation
                      isDropdown: true,
                      dropdownItems: ['male'.tr, 'female'.tr, 'other'.tr], // Translate dropdown items
                      initialValue: authController.gender.value,
                      onChanged: (value) => authController.gender.value = value,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.calendar_month_outlined,
                      label: "date_of_birth".tr, // Use .tr for dynamic translation
                      controller: dateController,
                      readOnly: true, // Prevent manual editing
                      onTap: () async {
                        DateTime initialDate = authController.dateOfBirth.value ?? DateTime.now();
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
                        label: "password".tr, // Use .tr for dynamic translation
                        isPassword: true,
                        controller: passwordController,
                        onChanged: (value) => authController.password.value = value,
                      ),
                    if (!isEdit)
                      CustomTextField(
                        suffixIcon: Icons.visibility_off_outlined,
                        label: "confirm_password".tr, // Use .tr for dynamic translation
                        isPassword: true,
                        controller: confirmPasswordController,
                        onChanged: (value) => authController.confirmPassword.value = value,
                      ),
                    const SizedBox(height: 20),
                    if (isEdit)
                      CustomButton(
                        text: "save_changes".tr, // Use .tr for dynamic translation
                        onPressed: () => authController.updateProfile(),
                      ),
                    if (!isEdit)
                      CustomButton(
                        text: "sign_up".tr, // Use .tr for dynamic translation
                        onPressed: () => authController.createAccount(),
                      ),
                    if (!isEdit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("already_have_account".tr), // Use .tr for dynamic translation
                          TextButton(
                            onPressed: () => Get.toNamed('/login'),
                            child: Text("login".tr), // Use .tr for dynamic translation
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