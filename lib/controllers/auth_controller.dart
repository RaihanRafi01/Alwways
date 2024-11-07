import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  // Reactive variables for user input
  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var contact = ''.obs;
  var location = ''.obs;
  var gender = ''.obs;
  var dateOfBirth = Rxn<DateTime>();
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var verificationCode = ''.obs;

  get signup => null;

  // Login method
  void login() {
    // Logic for login (e.g., API call for login)
  }

  // Reset password method
  void resetPassword() {
    // Logic for resetting password (e.g., API call for password reset)
  }

  // Verify code method
  void verifyCode() {
    // Logic for verifying the code (e.g., OTP verification)
  }

  // Create Account method (for signup)
  void createAccount() {
    // Validate inputs before proceeding
    if (firstName.value.isEmpty ||
        lastName.value.isEmpty ||
        email.value.isEmpty ||
        contact.value.isEmpty ||
        location.value.isEmpty ||
        gender.value.isEmpty ||
        dateOfBirth.value == null ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    // Check if passwords match
    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    // Logic to create an account (e.g., API call to register user)
    // Example API call for creating account
    // authService.createAccount(firstName.value, lastName.value, email.value, contact.value, location.value, gender.value, dateOfBirth.value, password.value);

    // Show success message
    Get.snackbar('Success', 'Account created successfully!');
  }

// Additional utility methods (e.g., for OTP, verification, etc.) can be added here
}
