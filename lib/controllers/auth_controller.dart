import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/home/home_splash.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service/api_service.dart';

class AuthController extends GetxController {
  final ApiService _service = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  var isLoading = false.obs;

  // Reactive variables for user input
  var firstName = ''.obs, lastName = ''.obs, email = ''.obs,
      contact = ''.obs, location = ''.obs, gender = ''.obs;
  var dateOfBirth = Rxn<DateTime>(), password = ''.obs, confirmPassword = ''.obs;
  var pickedImage = Rxn<XFile>();

  // Store tokens securely
  Future<void> storeTokens(String accessToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
  }

  // Setter for profile image
  void setProfileImage(XFile image) => pickedImage.value = image;

  // Handle account creation
  Future<void> createAccount() async {
    if (_isInputValid()) {
      await _signUp();
    }
  }

  // Validate user inputs
  // Validate user inputs
  bool _isInputValid() {
    // Check for empty Rx<String> fields and null profile picture
    if ([firstName, lastName, email, contact, location, gender, password, confirmPassword]
        .any((field) => field.value.isEmpty) || pickedImage.value == null) {
      Get.snackbar('Error', 'Please fill in all fields');
      return false;
    }

    // Check for DateOfBirth field (non-Rx type, direct check)
    if (dateOfBirth.value == null) {
      Get.snackbar('Error', 'Please select a date of birth');
      return false;
    }

    // Check if passwords match
    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }

    return true;
  }



  // Sign-up process
  Future<void> _signUp() async {
    isLoading.value = true;
    try {
      final response = await _service.signUp(
          firstName.value, lastName.value, email.value, contact.value,
          location.value, gender.value, dateOfBirth.value.toString(),
          password.value, pickedImage.value!);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Account created successfully!');
        Get.offAll(LoginScreen());
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Sign-up failed';
        Get.snackbar('Error', message);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String username, String password) async {
    isLoading.value = true; // Show the loading screen
    try {
      final http.Response response = await _service.login(username, password);

      print(':::::::::::::::RESPONSE:::::::::::::::::::::${response.body
          .toString()}');
      print(':::::::::::::::CODE:::::::::::::::::::::${response.statusCode}');
      print(':::::::::::::::REQUEST:::::::::::::::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming the server responds with success on code 200 or 201
        final responseBody = jsonDecode(response.body);

        print(
            ':::::::::::::::responseBody:::::::::::::::::::::${responseBody}');


        final accessToken = responseBody['token'];


        // Store the tokens securely
        await storeTokens(accessToken);


        // SharedPreferences

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // User is logged in


      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Error', responseBody['message'] ?? 'Sign-up failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Error: $e');
    } finally {
      isLoading.value = false; // Hide the loading screen
    }
  }
}
