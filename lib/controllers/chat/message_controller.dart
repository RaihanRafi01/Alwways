import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playground_02/controllers/chat/question_controller.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/widgets/chat/userMessage.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';
import 'botLanding_controller.dart';

class MessageController extends GetxController {
  var messages = <Widget>[].obs;
  var userAnswers = <Map<String, String>>[].obs;
  final QuestionController questionController = Get.put(QuestionController());
  final BotController botController = Get.find<BotController>();
  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    final sectionId = botController.selectedSectionId.value; // Use ID for fetching questions
    print("Initializing MessageController with sectionId: $sectionId");
    fetchQuestionsAndAsk(sectionId);
  }

  Future<void> fetchQuestionsAndAsk(String sectionId) async {
    await questionController.fetchQuestions(sectionId);
    askQuestion();
  }

  void askQuestion() {
    final currentQuestion = questionController.getCurrentQuestion();
    print("Asking question: $currentQuestion");
    if (currentQuestion != 'No more questions') {
      messages.add(BotMessage(message: currentQuestion));
    } else {
      messages.add(const BotMessage(message: "All questions answered!"));
    }
  }

  void sendMessage(String userAnswer) {
    if (userAnswer.trim().isEmpty) return;

    final currentQuestion = questionController.getCurrentQuestion();
    messages.add(UserMessage(message: userAnswer));
    userAnswers.add({'question': currentQuestion, 'answer': userAnswer});

    if (questionController.isSubQuestionMode.value) {
      _handleSubQuestionAnswer(currentQuestion, userAnswer);
    } else {
      _handleGenerateSubQuestion(currentQuestion, userAnswer);
    }
  }

  Future<void> _handleGenerateSubQuestion(String question, String answer) async {
    final response = await apiService.generateSubQuestion(question, answer);
    print(':::::::::::::: Status Code: ${response.statusCode}');
    print('::::::::::::::: Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(), // Now returns the index as a string
        question,
        answer,
      );
      print(':::saveResponse::::::::::: Status Code: ${saveResponse.statusCode}');
      print('::::saveResponse::::::::::: Response Body: ${saveResponse.body}');
      final data = jsonDecode(response.body);
      final subQuestions = List<String>.from(data['content']);
      questionController.setSubQuestions(subQuestions);
      askQuestion();
    } else if (response.statusCode == 400) {
      messages.add(const BotMessage(message: "Could you please elaborate more?"));
    } else {
      Get.snackbar('Error', 'Failed to generate sub-questions');
    }
  }

  Future<void> _handleSubQuestionAnswer(String subQuestion, String answer) async {
    final relevancyResponse = await apiService.checkRelevancy(subQuestion, answer);
    print(':::relevancyResponse::::::::::: Status Code: ${relevancyResponse.statusCode}');
    print(':::::relevancyResponse:::::::::: Response Body: ${relevancyResponse.body}');
    if (relevancyResponse.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(), // Now returns the index as a string
        subQuestion,
        answer,
      );
      print(':::saveResponse::::::::::: Status Code: ${saveResponse.statusCode}');
      print('::::saveResponse::::::::::: Response Body: ${saveResponse.body}');
      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        questionController.nextQuestion();
        askQuestion();
      } else {
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
    } else if (relevancyResponse.statusCode == 400) {
      messages.add(const BotMessage(message: "Could you provide a more relevant answer?"));
    } else {
      Get.snackbar('Error', 'Failed to check relevancy: ${relevancyResponse.statusCode}');
    }
  }

  var hasText = false.obs;

  void updateHasText(String text) {
    hasText.value = text.isNotEmpty;
  }
}