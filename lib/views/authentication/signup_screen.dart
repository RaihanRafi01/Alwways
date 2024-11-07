import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/widgets/custom_button.dart';
import 'package:playground_02/widgets/custom_textField.dart';
import 'package:playground_02/widgets/profileImage.dart';
import '../../controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController dateController = TextEditingController();
  XFile? _pickedImage; // To store the picked image

  // Function to pick image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image; // Update state with selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create account", textAlign: TextAlign.center),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(
                image: _pickedImage, // Pass the picked image
                onTap: _pickImage,  // Trigger image picker on tap
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "First Name",
                      onChanged: (value) => authController.firstName.value = value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      label: "Last Name",
                      onChanged: (value) => authController.lastName.value = value,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                label: "Email address",
                prefixIcon: Icons.email_outlined,
                onChanged: (value) => authController.email.value = value,
              ),
              CustomTextField(
                label: "Contact",
                prefixIcon: Icons.phone,
                onChanged: (value) => authController.contact.value = value,
              ),
              CustomTextField(
                label: "Location",
                prefixIcon: Icons.location_on_outlined,
                onChanged: (value) => authController.location.value = value,
              ),
              CustomTextField(
                label: "Gender",
                isDropdown: true,
                dropdownItems: ['Male', 'Female', 'Other'],
                onChanged: (value) => authController.gender.value = value,
              ),
              CustomTextField(
                prefixIcon: Icons.calendar_month_outlined,
                label: "Date of Birth",
                controller: dateController,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    authController.dateOfBirth.value = pickedDate;
                  }
                },
              ),
              CustomTextField(
                suffixIcon: Icons.visibility_off_outlined,
                label: "Password",
                isPassword: true,
                onChanged: (value) => authController.password.value = value,
              ),
              CustomTextField(
                suffixIcon: Icons.visibility_off_outlined,
                label: "Confirm Password",
                isPassword: true,
                onChanged: (value) => authController.confirmPassword.value = value,
              ),
              const SizedBox(height: 20),
              CustomButton(text: "SIGN UP", onPressed: (){}),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Get.toNamed('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green, // Set the text color to green
                    ),
                    child: const Text("Login"),
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
