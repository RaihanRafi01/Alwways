import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playground_02/widgets/chat/userMessage.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';

class MessageController extends GetxController {
  var messages = <Widget>[].obs;
  var userMessages = <String>[]; // Store all user messages for batch processing
  var isPromptVisible = true.obs; // Track the visibility of the prompt
  var hasText = false.obs; // Track if there's text in the input field

  void updateHasText(String text) {
    hasText.value = text.isNotEmpty;
  }

  void sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      userMessages.add(message); // Store the message for API request
      messages.add(UserMessage(message: message)); // Display user message

      // Show Yes/No prompt after each user message
      if (isPromptVisible.value) {
        messages.add(
          BotMessage(
            message: "Would you like to generate a book from your stories?",
            actions: [
              TextButton(
                onPressed: () {
                  _handleButtonClick(false); // Handle No button click
                },
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () {
                  _handleButtonClick(true); // Handle Yes button click
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleButtonClick(bool isYes) {
    // Remove the Yes/No prompt after a button click
    isPromptVisible.value = false; // Hide the prompt
    messages.removeWhere((message) =>
    message is BotMessage &&
        message.message == "Would you like to generate a book from your stories?");

    // Add the corresponding response message
    if (isYes) {
      generateBook(); // Call generateBook if the user clicked Yes
      messages.add(const BotMessage(message: "Generating the book... 📖"));
    } else {
      messages.add(const BotMessage(message: "Alright, no problem! Let me know if you change your mind."));
    }
  }

  void generateBook() async {
    if (userMessages.isNotEmpty) {
      // Display static messages before making the API call
      messages.add(const BotMessage(message: "Gathering your stories... 📖"));
      messages.add(const BotMessage(message: "Please wait while I compile everything into a book-like format."));

      final requestBody = jsonEncode({
        "stories": userMessages
      });

      try {
        final response = await http.post(
          Uri.parse('http://your-fastapi-url.com/analyze_story'),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          String botMessage;
          if (responseData.containsKey("book")) {
            botMessage = responseData["book"];
          } else if (responseData.containsKey("analyses")) {
            botMessage = responseData["analyses"].join("\n\n");
          } else {
            botMessage = "Unexpected response format.";
          }

          messages.add(BotMessage(message: botMessage));
        } else {
          messages.add(const BotMessage(message: "Failed to generate the book. Please try again."));
        }
      } catch (e) {
        messages.add(const BotMessage(message: "Could not connect to server."));
      }
    } else {
      messages.add(const BotMessage(message: "No stories found to generate the book. Please add some stories first."));
    }
  }
}
