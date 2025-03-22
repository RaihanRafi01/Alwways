import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playground_02/views/authentication/forgot_password_screen.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/authentication/set_new_password_screen.dart';
import 'package:playground_02/views/home/home_splash.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service/api_service.dart';
import '../views/authentication/verify_code_screen.dart';

class AuthController extends GetxController {
  final ApiService _service = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  var isLoading = false.obs;

  // Reactive variables for user input and profile data
  var firstName = ''.obs, lastName = ''.obs, email = ''.obs,
      contact = ''.obs, location = ''.obs, gender = ''.obs;
  var dateOfBirth = Rxn<DateTime>(), password = ''.obs, confirmPassword = ''.obs;
  var pickedImage = Rxn<XFile>();
  var profilePictureUrl = ''.obs; // Added for profile picture URL

  // Getters for computed values
  String get fullName => '${firstName.value} ${lastName.value}';
  String get formattedDateOfBirth => dateOfBirth.value != null
      ? DateFormat('dd/MM/yyyy').format(dateOfBirth.value!)
      : '';

  // Store tokens securely
  Future<void> storeTokens(String accessToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
  }

  // Setter for profile image
  void setProfileImage(XFile image) => pickedImage.value = image;

  // Pick image from gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = image;
    }
  }

  // Fetch profile data from API
  Future<void> fetchProfile() async {
    try {
      String? token = await _storage.read(key: 'access_token');
      if (token == null) {
        Get.snackbar('Error', 'No token found. Please log in.');
        return;
      }

      final response = await _service.getProfile(token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        profilePictureUrl.value = data['profilePicture'] ?? '';
        firstName.value = data['firstname'] ?? '';
        lastName.value = data['lastname'] ?? '';
        email.value = data['email'] ?? '';
        contact.value = data['mobile'] ?? '';
        location.value = data['location'] ?? '';
        gender.value = data['gender'] ?? '';
        dateOfBirth.value = data['dateOfBirth'] != null
            ? DateTime.parse(data['dateOfBirth'])
            : null;
      } else {
        Get.snackbar('Error', 'Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  // Update profile via API
  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      String? token = await _storage.read(key: 'access_token');
      if (token == null) {
        Get.snackbar('Error', 'No token found. Please log in.');
        return;
      }

      Map<String, String> userData = {
        'firstname': firstName.value,
        'lastname': lastName.value,
        'email': email.value,
        'mobile': contact.value,
        'location': location.value,
        'gender': gender.value,
        'dateOfBirth': dateOfBirth.value?.toIso8601String().substring(0, 10) ?? '',
      };

      if (password.value.isNotEmpty) userData['password'] = password.value;

      // Log pickedImage details for debugging
      if (pickedImage.value != null) {
        print('::::::::::::::::::::UPDATE : pickedImage path: ${pickedImage.value!.path}');
        print('::::::::::::::::::::UPDATE : pickedImage name: ${pickedImage.value!.name}');
        final file = File(pickedImage.value!.path);
        print('::::::::::::::::::::UPDATE : pickedImage exists: ${file.existsSync()}');
        String mimeType = pickedImage.value!.name.toLowerCase().endsWith('.png')
            ? 'image/png'
            : pickedImage.value!.name.toLowerCase().endsWith('.jpg') || pickedImage.value!.name.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : 'unknown';
        print('::::::::::::::::::::UPDATE : pickedImage inferred MIME type: $mimeType');
      } else {
        print('::::::::::::::::::::UPDATE : pickedImage is null');
      }

      final response = await _service.updateProfile(token, userData, pickedImage.value);

      print('::::::::::::::::::::UPDATE : request ${jsonEncode(userData)}');
      print('::::::::::::::::::::UPDATE : statusCode ${response.statusCode}');
      print('::::::::::::::::::::UPDATE : body ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Profile updated successfully');
        await fetchProfile(); // Refresh profile data
        pickedImage.value = null; // Clear picked image
        Get.back(); // Return to ProfileScreen
      } else {
        Get.snackbar('Error', 'Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Handle account creation
  Future<void> createAccount() async {
    if (_isInputValid()) {
      await _signUp();
    }
  }

  // Validate user inputs
  bool _isInputValid() {
    if ([firstName, lastName, email, contact, location, gender, password, confirmPassword]
        .any((field) => field.value.isEmpty) || pickedImage.value == null) {
      Get.snackbar('Error', 'Please fill in all fields');
      return false;
    }
    if (dateOfBirth.value == null) {
      Get.snackbar('Error', 'Please select a date of birth');
      return false;
    }
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

  // Login, OTP, and reset password methods remain unchanged
  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await _service.login(username, password);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['token'];
        await storeTokens(accessToken);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Get.offAll(const HomeSplashscreen());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Error', responseBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp(String email) async {
    isLoading.value = true;
    try {
      final response = await _service.forgotPasswordOTP(email);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAll(VerifyCodeScreen(email: email));
      } else if (response.statusCode == 404) {
        Get.snackbar('Warning!', 'User not found in this Email');
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Error', responseBody['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    isLoading.value = true;
    try {
      final response = await _service.verifyOtp(email, otp);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAll(SetNewPasswordScreen(email: email, otp: otp));
      } else if (response.statusCode == 404) {
        Get.snackbar('Warning!', 'User not found in this Email');
      } else if (response.statusCode == 400) {
        Get.snackbar('Warning!', 'Invalid verification code');
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Error', responseBody['message'] ?? 'Verification failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    isLoading.value = true;
    try {
      final response = await _service.resetPassword(email, otp, password);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offAll(LoginScreen());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Error', responseBody['message'] ?? 'Reset failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    contact.value = '';
    location.value = '';
    gender.value = '';
    dateOfBirth.value = null;
    profilePictureUrl.value = '';
    pickedImage.value = null;
    Get.offAll(LoginScreen());
  }
}