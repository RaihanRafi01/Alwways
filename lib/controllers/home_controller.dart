import 'dart:convert';
import 'package:get/get.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/services/database/databaseHelper.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final DatabaseHelper dbHelper = DatabaseHelper();
  var message = 'Loading...'.obs; // Observable string for the dynamic message

  @override
  void onInit() {
    super.onInit();
    fetchMessage();
  }

  Future<void> fetchMessage() async {
    try {
      print('Fetching message...');
      print('User ID: ${authController.userId.value}');

      // Ensure profile is loaded if userId is empty
      /*if (authController.userId.value.isEmpty) {
        print('User ID is empty, attempting to fetch profile...');
        await authController.fetchProfile();
        print('Profile fetched, new User ID: ${authController.userId.value}');
      }*/

      // If userId is still empty, use welcome message
      if (authController.userId.value.isEmpty) {
        message.value = "welcome_new_user".tr;
        print('No user ID, set welcome message: ${message.value}');
        return;
      }

      final db = await dbHelper.database;
      print('Database opened, querying chat history...');

      // Query to find the most recent chat history entry for the user's books
      final result = await db.rawQuery('''
        SELECT ch.sectionId, s.name
        FROM chat_history ch
        JOIN books b ON ch.bookId = b.id
        JOIN sections s ON ch.sectionId = s.id
        WHERE b.userId = ?
        ORDER BY ch.timestamp DESC
        LIMIT 1
      ''', [authController.userId.value]);

      print('Query result: $result');

      if (result.isEmpty) {
        // No chat history exists for the user
        message.value = "welcome_new_user".tr;
        print('No chat history found, set welcome message: ${message.value}');
      } else {
        // Get the section name from the most recent chat history entry
        final sectionName = result.first['name'] as String;
        print('Section name from DB: $sectionName');

        // Use trParams to substitute sectionName
        message.value = "thank_you_section".trParams({'sectionName': sectionName});
        print('Set message with trParams: ${message.value}');

        // Fallback: If {sectionName} is still in the string, manually replace it
        if (message.value.contains('{sectionName}')) {
          message.value = "thank_you_section".tr.replaceAll('{sectionName}', sectionName);
          print('Fallback applied, updated message: ${message.value}');
        }
      }
    } catch (e) {
      print('Error in fetchMessage: $e');
      message.value = "error".tr; // Fallback to a generic error message
    }
  }
}