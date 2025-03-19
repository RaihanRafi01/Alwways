import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playground_02/controllers/chat/question_controller.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/services/database/databaseHelper.dart';
import 'package:playground_02/widgets/chat/userMessage.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';
import '../../services/model/bookModel.dart';
import '../book/bookLanding_controller.dart';
import 'botLanding_controller.dart';

class MessageController extends GetxController {
  var messages = <Widget>[].obs;
  var userAnswers = <Map<String, String>>[].obs;
  final QuestionController questionController = Get.put(QuestionController());
  final BotController botController = Get.put(BotController());
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Show loading message with animated dots
  void _showLoadingMessage() {
    messages.add(const BotMessage(message: "", isLoading: true));
  }

  // Remove the loading message
  void _removeLoadingMessage() {
    if (messages.isNotEmpty && messages.last is BotMessage && (messages.last as BotMessage).isLoading) {
      messages.removeLast();
    }
  }

  @override
  void onInit() {
    super.onInit();
    final sectionId = botController.selectedSectionId.value;
    print("Initializing MessageController with sectionId: $sectionId");
    fetchQuestionsAndLoadHistory(sectionId);
  }

  Future<void> fetchQuestionsAndLoadHistory(String sectionId) async {
    await questionController.fetchQuestions(sectionId);
    final bookId = botController.selectedBookId.value;
    final episodeID = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeID);
    print("Chat history for bookId: $bookId, episodeId : $episodeID ,  sectionId: $sectionId: $history");

    for (var entry in history) {
      messages.add(BotMessage(message: entry['question']!));
      messages.add(UserMessage(message: entry['answer']!));
      userAnswers.add({'question': entry['question']!, 'answer': entry['answer']!});
    }

    final mainQuestions = questionController.questions.map((q) => q.text).toList();
    final answeredMainQuestions = history.where((entry) => mainQuestions.contains(entry['question'])).length;
    questionController.currentQuestionIndex.value = answeredMainQuestions;
    if (questionController.currentQuestionIndex.value >= questionController.questions.length) {
      questionController.currentQuestionIndex.value = questionController.questions.length;
    }

    await _calculateAndPrintCompletionPercentage(sectionId, answeredMainQuestions);
    askQuestion();
  }

  void askQuestion() {
    _removeLoadingMessage(); // Ensure loading is removed before adding a new question
    final currentQuestion = questionController.getCurrentQuestion();
    print("Asking question: $currentQuestion");
    if (currentQuestion != 'No more questions') {
      messages.add(BotMessage(message: currentQuestion));
    } else {
      messages.add(const BotMessage(message: "All questions answered!"));
    }
  }

  Future<void> sendMessage(String userAnswer) async {
    if (userAnswer.trim().isEmpty) return;

    final currentQuestion = questionController.getCurrentQuestion();
    messages.add(UserMessage(message: userAnswer));
    userAnswers.add({'question': currentQuestion, 'answer': userAnswer});

    final bookId = botController.selectedBookId.value;
    final sectionId = botController.selectedSectionId.value;

    _showLoadingMessage(); // Show loading animation before API call

    if (questionController.isSubQuestionMode.value) {
      await _handleSubQuestionAnswer(currentQuestion, userAnswer);
    } else {
      await _handleGenerateSubQuestion(currentQuestion, userAnswer);
    }

    final history = await dbHelper.getChatHistory(bookId, sectionId);
    final mainQuestions = questionController.questions.map((q) => q.text).toList();
    final answeredMainQuestions = history.where((entry) => mainQuestions.contains(entry['question'])).length;
    await _calculateAndPrintCompletionPercentage(sectionId, answeredMainQuestions);
  }

  Future<void> _calculateAndPrintCompletionPercentage(String sectionId, int answeredMainQuestions) async {
    final sections = await dbHelper.getSections();
    final currentSection = sections.firstWhere((section) => section.id == sectionId);
    final totalQuestions = currentSection.questionsCount ?? 0;
    final completionPercentage = totalQuestions > 0 ? (answeredMainQuestions / totalQuestions) * 100 : 0;
    print("Section: ${currentSection.name}, Total Questions: $totalQuestions, Answered Main: $answeredMainQuestions, Completion: ${completionPercentage.toStringAsFixed(2)}%");

    final bookId = botController.selectedBookId.value;
    final episodeIndex = botController.getSelectedSectionId();
    final episodeID = botController.selectedEpisodeId.value;
    try {
      final response = await apiService.updateEpisodePercentage(bookId, episodeIndex, completionPercentage);
      print(':::updateEpisodePercentage::: Status Code: ${response.statusCode}');
      print(':::updateEpisodePercentage::: Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final db = await dbHelper.database;
        final episodeMaps = await db.query(
          'episodes',
          where: 'bookId = ? AND id = ?',
          whereArgs: [bookId, episodeID],
        );

        if (episodeMaps.isNotEmpty) {
          final episode = Episode.fromMap(episodeMaps.first);
          final updatedEpisode = episode.copyWith(percentage: completionPercentage.toDouble());
          await dbHelper.updateEpisode(updatedEpisode);
          print("Updated episode percentage in database: ${updatedEpisode.percentage}");
        }

        final bookController = Get.put(BookLandingController());
        await bookController.fetchBooks();
        print("Refreshed BookLandingController with updated data");
      } else {
        Get.snackbar('Error', 'Failed to update percentage: ${response.statusCode}');
      }
    } catch (e) {
      print("Error updating percentage: $e");
      Get.snackbar('Error', 'Failed to update percentage: $e');
    }
  }

  Future<void> _handleGenerateSubQuestion(String question, String answer) async {
    final response = await apiService.generateSubQuestion(question, answer);
    print(':::::1111::::::::: Status Code: ${response.statusCode}');
    print('::::::11111::::::::: Response Body: ${response.body}');
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
        askQuestion(); // Loading will be removed here
      } else {
        _removeLoadingMessage();
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
    } else if (response.statusCode == 400) {
      _removeLoadingMessage();
      messages.add(BotMessage(message: "Could you please elaborate on : $question"));
    } else {
      _removeLoadingMessage();
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
        askQuestion(); // Loading will be removed here
      } else {
        _removeLoadingMessage();
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
    } else if (relevancyResponse.statusCode == 400) {
      _removeLoadingMessage();
      messages.add(BotMessage(message: "Could you provide a more relevant answer on : $subQuestion"));
    } else {
      _removeLoadingMessage();
      Get.snackbar('Error', 'Failed to check relevancy: ${relevancyResponse.statusCode}');
    }
  }

  var hasText = false.obs;

  void updateHasText(String text) {
    hasText.value = text.isNotEmpty;
  }
}