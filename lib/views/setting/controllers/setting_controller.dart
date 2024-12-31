import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SettingController extends GetxController {
  var isWritingReminderOn = false.obs;
  var selectedLanguage = 'English'.obs;
  var isLoading = false.obs; // Reactive loading state
  //final ApiService _service = ApiService();

  // Toggle method for the Writing Reminder
  void toggleWritingReminder(bool value) {
    isWritingReminderOn.value = value;
  }

  // Change the language
  void changeLanguage(String newLanguage) {
    selectedLanguage.value = newLanguage;
  }

}
