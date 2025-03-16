import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playground_02/controllers/chat/question_controller.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/widgets/chat/userMessage.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';
import 'botLanding_controller.dart';
import '../../services/database/databaseHelper.dart';

class MessageController extends GetxController {
  var messages = <Widget>[].obs;
  var userAnswers = <Map<String, String>>[].obs;
  final QuestionController questionController = Get.put(QuestionController());
  final BotController botController = Get.find<BotController>();
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    final sectionId = botController.selectedSectionId.value;
    print("Initializing MessageController with sectionId: $sectionId");
    fetchQuestionsAndLoadHistory(sectionId);
  }

  Future<void> fetchQuestionsAndLoadHistory(String sectionId) async {
    // Fetch questions
    await questionController.fetchQuestions(sectionId);

    // Load chat history
    final bookId = botController.selectedBookId.value;
    final history = await dbHelper.getChatHistory(bookId, sectionId);
    print("Chat history for bookId: $bookId, sectionId: $sectionId: $history");

    // Add history to messages
    for (var entry in history) {
      messages.add(BotMessage(message: entry['question']!));
      messages.add(UserMessage(message: entry['answer']!));
      userAnswers.add({'question': entry['question']!, 'answer': entry['answer']!});
    }

    // Skip answered questions
    final answeredQuestions = history.map((e) => e['question']).toList();
    questionController.currentQuestionIndex.value = answeredQuestions.length;
    if (questionController.currentQuestionIndex.value >= questionController.questions.length) {
      questionController.currentQuestionIndex.value = questionController.questions.length;
    }

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
    print(':::::::::::::: HIT _handleGenerateSubQuestion ');
    final response = await apiService.generateSubQuestion(question, answer);
    print(':::::::::::::: Status Code: ${response.statusCode}');
    print('::::::::::::::: Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(),
        question,
        answer,
      );
      print(':::saveResponse::::::::::: Status Code: ${saveResponse.statusCode}');
      print('::::saveResponse::::::::::: Response Body: ${saveResponse.body}');
      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        await dbHelper.insertChatHistory(
          botController.selectedBookId.value,
          botController.selectedSectionId.value,
          question,
          answer,
        );
        final data = jsonDecode(response.body);
        final subQuestions = List<String>.from(data['content']);
        questionController.setSubQuestions(subQuestions);
        askQuestion();
      } else {
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
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
        botController.getSelectedSectionId(),
        subQuestion,
        answer,
      );
      print(':::saveResponse::::::::::: Status Code: ${saveResponse.statusCode}');
      print('::::saveResponse::::::::::: Response Body: ${saveResponse.body}');
      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        await dbHelper.insertChatHistory(
          botController.selectedBookId.value,
          botController.selectedSectionId.value,
          subQuestion,
          answer,
        );
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