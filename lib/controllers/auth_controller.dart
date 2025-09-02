import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  final RxBool isProfileLoaded = false.obs;

  // Reactive variables for user input and profile data
  var firstName = ''.obs,
      lastName = ''.obs,
      email = ''.obs,
      contact = ''.obs,
      location = ''.obs,
      gender = 'Male'.obs;
  var dateOfBirth = Rxn<DateTime>(),
      password = ''.obs,
      confirmPassword = ''.obs;
  var pickedImage = Rxn<XFile>();
  var profilePictureUrl = ''.obs; // Added for profile picture URL
  var subscriptionType = ''.obs;
  var userId = ''.obs;

  // Getters for computed values
  String get fullName => '${firstName.value} ${lastName.value}';

  String get formattedDateOfBirth => dateOfBirth.value != null
      ? DateFormat('dd/MM/yyyy').format(dateOfBirth.value!)
      : '';

  @override
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
    print(' :::::: ========>>>>>> 🪃 hit fetch profile');
    try {
      String? token = await _storage.read(key: 'access_token');
      if (token == null) {
        Get.snackbar('error'.tr, 'no_token_found'.tr); // Using localization key
        return;
      }

      final response = await _service.getProfile(token);
      if (response.statusCode == 200) {
        print(' :::::: hit fetch profile RESPONSE :::::::::::::: ${response.body}');
        final data = jsonDecode(response.body);
        profilePictureUrl.value = data['profilePicture'] ?? '';
        userId.value = data['_id'] ?? '';
        firstName.value = data['firstname'] ?? '';
        lastName.value = data['lastname'] ?? '';
        email.value = data['email'] ?? '';
        contact.value = data['mobile'] ?? '';
        location.value = data['location'] ?? '';
        gender.value = data['gender'] ?? '';
        subscriptionType.value = data['subscriptionType'] ?? 'Free';
        dateOfBirth.value = data['dateOfBirth'] != null
            ? DateTime.parse(data['dateOfBirth'])
            : null;

        isProfileLoaded.value = true;
      } else if (response.statusCode == 401) {
        Get.offAll(LoginScreen());
      } else {
        Get.snackbar('error'.tr, 'failed_to_fetch_profile'.tr); // Using localization key
        isProfileLoaded.value = false;
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
      isProfileLoaded.value = false;
    }
  }

  // Update profile via API
  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      String? token = await _storage.read(key: 'access_token');
      if (token == null) {
        Get.snackbar('error'.tr, 'no_token_found'.tr); // Using localization key
        return;
      }

      Map<String, String> userData = {
        'firstname': firstName.value,
        'lastname': lastName.value,
        'email': email.value,
        'mobile': contact.value,
        'location': location.value,
        'gender': gender.value,
        'dateOfBirth':
        dateOfBirth.value?.toIso8601String().substring(0, 10) ?? '',
      };

      // Log pickedImage details for debugging
      if (pickedImage.value != null) {
        print(
            '::::::::::::::::::::UPDATE : pickedImage path: ${pickedImage.value!.path}');
        print(
            '::::::::::::::::::::UPDATE : pickedImage name: ${pickedImage.value!.name}');
        final file = File(pickedImage.value!.path);
        print(
            '::::::::::::::::::::UPDATE : pickedImage exists: ${file.existsSync()}');
        String mimeType = pickedImage.value!.name.toLowerCase().endsWith('.png')
            ? 'image/png'
            : pickedImage.value!.name.toLowerCase().endsWith('.jpg') ||
            pickedImage.value!.name.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : 'unknown';
        print(
            '::::::::::::::::::::UPDATE : pickedImage inferred MIME type: $mimeType');
      } else {
        print('::::::::::::::::::::UPDATE : pickedImage is null');
      }

      final response =
      await _service.updateProfile(token, userData, pickedImage.value);

      print('::::::::::::::::::::UPDATE : request ${jsonEncode(userData)}');
      print('::::::::::::::::::::UPDATE : statusCode ${response.statusCode}');
      print('::::::::::::::::::::UPDATE : body ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr, 'profile_updated'.tr); // Using localization key
        await fetchProfile(); // Refresh profile data
        pickedImage.value = null; // Clear picked image
        Get.back(); // Return to ProfileScreen
      } else {
        Get.snackbar('error'.tr, 'failed_to_update_profile'.tr); // Using localization key
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
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
    String genderValue = gender.value.isEmpty ? 'Male' : gender.value;
    String locationValue = location.value.isEmpty ? 'Location' : location.value;

    // Validate that none of the required fields are empty
    if ([
      firstName.value,
      lastName.value,
      email.value,
      contact.value,
      locationValue,
      genderValue,
      password.value,
      confirmPassword.value
    ].any((field) => field.isEmpty)) {
      Get.snackbar('warning'.tr, 'please_fill_all_fields'.tr); // Using localization key
      return false;
    }

    // If date of birth is null, show an error
    if (dateOfBirth.value == null) {
      Get.snackbar('warning'.tr, 'please_select_date_of_birth'.tr); // Using localization key
      return false;
    }

    // If passwords do not match, show an error
    if (password.value != confirmPassword.value) {
      Get.snackbar('warning'.tr, 'passwords_do_not_match'.tr); // Using localization key
      return false;
    }

    return true;
  }

  // Sign-up process
  Future<void> _signUp() async {
    isLoading.value = true;
    try {
      // Map gender values to English
      String mappedGender;
      switch (gender.value) {
        case 'Masculino':
          mappedGender = 'Male';
          break;
        case 'Femenino':
          mappedGender = 'Female';
          break;
        case 'Otro':
          mappedGender = 'Other';
          break;
        default:
          mappedGender = gender.value; // Fallback to original value if no match
      }

      XFile imageToUpload = pickedImage.value ?? await _getDefaultAvatar();

      final response = await _service.signUp(
        firstName.value,
        lastName.value,
        email.value,
        contact.value,
        location.value,
        mappedGender,
        dateOfBirth.value.toString(),
        password.value,
        imageToUpload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('success'.tr, 'account_created_success'.tr); // Using localization key
        Get.offAll(LoginScreen());
      } else {// Using localization key
        Get.snackbar('error'.tr, 'sign_up_failed'.tr); // Using localization key
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
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
        Get.snackbar('error'.tr, 'login_failed'.tr); // Using localization key
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
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
        Get.snackbar('warning'.tr, 'user_not_found_in_email'.tr); // Using localization key
      } else {
        Get.snackbar('error'.tr, 'failed_to_send_otp'.tr); // Using localization key
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
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
        Get.snackbar('warning'.tr, 'user_not_found_in_email'.tr); // Using localization key
      } else if (response.statusCode == 400) {
        Get.snackbar('warning'.tr, 'invalid_verification_code'.tr); // Using localization key
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('error'.tr, responseBody['message'] ?? 'verification_failed'.tr); // Using localization key
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
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
        Get.snackbar('error'.tr, responseBody['message'] ?? 'reset_failed'.tr); // Using localization key
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'unexpected_error'.tr); // Using localization key
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

  Future<XFile> _getDefaultAvatar() async {
    final byteData = await DefaultAssetBundle.of(Get.context!).load('assets/images/auth/user.png');
    final file = File('${(await getTemporaryDirectory()).path}/user.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return XFile(file.path);
  }
}
