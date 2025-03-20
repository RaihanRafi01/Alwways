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
  late final sectionId;

  void _showLoadingMessage() {
    messages.add(const BotMessage(message: "", isLoading: true));
  }

  void _removeLoadingMessage() {
    if (messages.isNotEmpty && messages.last is BotMessage && (messages.last as BotMessage).isLoading) {
      messages.removeLast();
    }
  }

  @override
  void onInit() {
    super.onInit();
    sectionId = botController.selectedSectionId.value;
    fetchQuestionsAndLoadHistory(sectionId);
  }

  Future<void> fetchQuestionsAndLoadHistory(String sectionId) async {
    await questionController.fetchQuestions(sectionId);
    final bookId = botController.selectedBookId.value;
    final episodeID = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeID);

    messages.clear();
    userAnswers.clear();

    for (var entry in history) {
      messages.add(BotMessage(message: entry['question']!));
      messages.add(UserMessage(message: entry['answer']!));
      userAnswers.add({'question': entry['question']!, 'answer': entry['answer']!});
    }

    questionController.currentQuestionIndex.value = 0;
    questionController.skipToNextUnansweredQuestion(history);
    await _calculateAndPrintCompletionPercentage(sectionId); // Initial call on load
    askQuestion();
  }

  void askQuestion() {
    _removeLoadingMessage();
    final currentQuestion = questionController.getCurrentQuestion();
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
    _showLoadingMessage();

    if (questionController.isSubQuestionMode.value) {
      await _handleSubQuestionAnswer(currentQuestion, userAnswer);
      if (!questionController.isSubQuestionMode.value) {
        final history = await dbHelper.getChatHistory(bookId, sectionId);
        questionController.skipToNextUnansweredQuestion(history);
        askQuestion();
      }
    } else {
      await _handleGenerateSubQuestion(currentQuestion, userAnswer); // API call moved here
      if (!questionController.isSubQuestionMode.value) {
        final history = await dbHelper.getChatHistory(bookId, sectionId);
        questionController.skipToNextUnansweredQuestion(history);
        askQuestion();
      }
    }
    // Removed _calculateAndPrintCompletionPercentage from here
  }

  Future<void> _calculateAndPrintCompletionPercentage(String sectionId) async {
    final sections = await dbHelper.getSections();
    Section? currentSection;

    try {
      currentSection = sections.firstWhere((section) => section.id == sectionId);
    } catch (e) {
      print("Error: No section found for sectionId: $sectionId");
      Get.snackbar('Error', 'Section not found');
      return;
    }

    final totalQuestions = currentSection.questionsCount ?? 0;
    final bookId = botController.selectedBookId.value;
    final episodeID = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeID);

    final mainQuestions = questionController.questions.map((q) => q.text).toList();
    final uniqueAnsweredQuestions = history
        .where((entry) => mainQuestions.contains(entry['question']))
        .map((entry) => entry['question'])
        .toSet()
        .toList();
    final answeredMainQuestions = uniqueAnsweredQuestions.length;

    final completionPercentage = totalQuestions > 0 ? (answeredMainQuestions / totalQuestions) * 100 : 0;
    print("Section: ${currentSection.name}, Total: $totalQuestions, Answered: $answeredMainQuestions, Completion: ${completionPercentage.toStringAsFixed(2)}%");

    final episodeIndex = botController.getSelectedSectionId();
    try {
      final response = await apiService.updateEpisodePercentage(bookId, episodeIndex, completionPercentage);
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
        }
        final bookController = Get.put(BookLandingController());
        await bookController.fetchBooks();
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
    if (response.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(),
        question,
        answer,
      );
      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        await dbHelper.insertChatHistory(
          botController.selectedBookId.value,
          botController.selectedSectionId.value,
          question,
          answer,
        );
        // Call API only when main question is successfully answered
        await _calculateAndPrintCompletionPercentage(sectionId);
        final data = jsonDecode(response.body);
        final subQuestions = List<String>.from(data['content']);
        questionController.setSubQuestions(subQuestions);
        askQuestion();
      } else {
        _removeLoadingMessage();
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
    } else if (response.statusCode == 400) {
      _removeLoadingMessage();
      messages.add(BotMessage(message: "Could you please elaborate on: $question"));
    } else {
      _removeLoadingMessage();
      Get.snackbar('Error', 'Failed to generate sub-questions');
    }
  }

  Future<void> _handleSubQuestionAnswer(String subQuestion, String answer) async {
    final relevancyResponse = await apiService.checkRelevancy(subQuestion, answer);
    if (relevancyResponse.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(),
        subQuestion,
        answer,
      );
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
        _removeLoadingMessage();
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
    } else if (relevancyResponse.statusCode == 400) {
      _removeLoadingMessage();
      messages.add(BotMessage(message: "Could you provide a more relevant answer on: $subQuestion"));
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