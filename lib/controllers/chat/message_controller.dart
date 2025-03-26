import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/controllers/chat/question_controller.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/services/database/databaseHelper.dart';
import 'package:playground_02/widgets/chat/userMessage.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';
import '../../services/model/bookModel.dart';
import '../../views/chatWithAI/chatScreen.dart';
import '../book/bookLanding_controller.dart';
import 'botLanding_controller.dart';

class MessageController extends GetxController {
  var messages = <Widget>[].obs;
  var userAnswers = <Map<String, String>>[].obs;
  final QuestionController questionController = Get.put(QuestionController());
  final BotController botController = Get.put(BotController());
  final BookController bookController = Get.put(BookController());
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();
  String? sectionId;

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
    if (botController.selectedBookId.value.isNotEmpty) {
      sectionId = botController.selectedSectionId.value;
      print("Initializing MessageController with sectionId: $sectionId");
      fetchQuestionsAndLoadHistory(sectionId!);
    } else {
      print("MessageController initialized in initial chat mode (no book selected)");
    }
  }

  Future<void> fetchQuestionsAndLoadHistory(String sectionId) async {
    await questionController.fetchQuestions(sectionId);
    final bookId = botController.selectedBookId.value;
    final episodeID = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeID);
    print("Chat history for bookId: $bookId, episodeId: $episodeID, sectionId: $sectionId: $history");

    messages.clear();
    userAnswers.clear();

    for (var entry in history) {
      messages.add(BotMessage(message: entry['question']!));
      messages.add(UserMessage(message: entry['answer']!));
      userAnswers.add({'question': entry['question']!, 'answer': entry['answer']!});
    }

    questionController.currentQuestionIndex.value = 0;
    questionController.skipToNextUnansweredQuestion(history);
    await _calculateAndPrintCompletionPercentage(sectionId);
    askQuestion();
  }

  void askQuestion() {
    _removeLoadingMessage();
    final currentQuestion = questionController.getCurrentQuestion();
    print("Asking question: $currentQuestion (Index: ${questionController.currentQuestionIndex.value}, Total Questions: ${questionController.questions.length})");
    if (currentQuestion != 'No more questions') {
      messages.add(BotMessage(message: currentQuestion));
    } else {
      messages.add(const BotMessage(message: "All questions answered!"));
      print("All questions answered, checking for initial chat mode...");
      if (botController.selectedBookId.value.isEmpty) {
        print("Triggering book creation and navigation...");
        _createBookAndNavigate();
      }
    }
  }

  Future<void> sendMessage(String userAnswer) async {
    if (userAnswer.trim().isEmpty) return;

    final currentQuestion = questionController.getCurrentQuestion();
    print("User answered: '$userAnswer' to question: '$currentQuestion' (Index: ${questionController.currentQuestionIndex.value})");
    messages.add(UserMessage(message: userAnswer));
    userAnswers.add({'question': currentQuestion, 'answer': userAnswer});

    if (botController.selectedBookId.value.isEmpty) {
      print("In initial chat mode, advancing to next question...");
      questionController.nextQuestion();
      askQuestion();
      return;
    }

    final bookId = botController.selectedBookId.value;
    _showLoadingMessage();

    if (questionController.isSubQuestionMode.value) {
      await _handleSubQuestionAnswer(currentQuestion, userAnswer);
      if (!questionController.isSubQuestionMode.value) {
        final history = await dbHelper.getChatHistory(bookId, sectionId!);
        questionController.skipToNextUnansweredQuestion(history);
      }
    } else {
      await _handleGenerateSubQuestion(currentQuestion, userAnswer);
    }
  }

  Future<void> _createBookAndNavigate() async {
    print("Creating book with answers: ${userAnswers.toList()}");
    String bookName = userAnswers.firstWhere(
          (a) => a['question'] == 'What is your name?',
      orElse: () => {'answer': 'My Memoir'},
    )['answer'] ?? 'My Memoir';
    bookController.bookNameController.text = "$bookName's Life";

    // Show loading dialog immediately
    Get.dialog(
      const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Creating your book..."),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Prevent closing by tapping outside
    );

    try {
      // Step 1: Create the book
      print("Calling createBook()...");
      await bookController.createBook();

      print("Books after creation: ${botController.books.length}, Sections: ${botController.sections.length}");
      if (botController.books.isEmpty || botController.sections.isEmpty) {
        throw Exception("Failed to initialize book or sections");
      }

      // Step 2: Get book, section, and episode IDs
      String newBookId = botController.books.first['id']!;
      String firstSectionId = botController.sections.first.id;
      Book newBook = bookController.books.firstWhere((b) => b.id == newBookId);
      String firstEpisodeId = newBook.episodes.isNotEmpty ? newBook.episodes.first.id : '';

      if (firstEpisodeId.isEmpty) {
        throw Exception("No episodes found for new book");
      }

      print("::::::::::::::: GGG ::::::::::::::::::::::: book id : $newBookId , sectionId : $firstSectionId , episodeId : $firstEpisodeId");

      // Step 3: Select book, section, and episode
      botController.selectBook(newBookId);
      botController.selectSection(firstSectionId);
      botController.selectedEpisodeId.value = firstEpisodeId;
      print("Selected section: $firstSectionId, episode: $firstEpisodeId");

      // Step 4: Fetch questions and load history
      sectionId = firstSectionId;
      await questionController.fetchQuestions(firstSectionId);

      // Step 5: Wait an additional 3 seconds after all operations
      print("Waiting 3 seconds before navigation...");
      await Future.delayed(const Duration(seconds: 3));

      // Step 6: Close loading dialog and navigate
      print("Navigating to ChatScreen...");
      Get.back(); // Close the loading dialog
      Get.off(() => ChatScreen(
        bookId: newBookId,
        sectionId: firstSectionId,
        episodeId: firstEpisodeId,
      ));
    } catch (e) {
      print("Error in book creation or question fetching: $e");
      Get.back(); // Close loading dialog
      Get.snackbar('Error', e.toString());
    }
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

    final totalQuestions = currentSection.questionsCount;
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
    print(':::generateSubQuestion::: Status Code: ${response.statusCode}');
    print(':::generateSubQuestion::: Response Body: ${response.body}');

    _removeLoadingMessage();

    if (response.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(),
        question,
        answer,
      );
      print(':::saveAnswer::: Status Code: ${saveResponse.statusCode}');
      print(':::saveAnswer::: Response Body: ${saveResponse.body}');
      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        await dbHelper.insertChatHistory(
          botController.selectedBookId.value,
          botController.selectedSectionId.value,
          question,
          answer,
        );
        await _calculateAndPrintCompletionPercentage(sectionId!);
        final data = jsonDecode(response.body);
        final subQuestions = List<String>.from(data['content']);
        questionController.setSubQuestions(subQuestions);
        askQuestion();
      } else {
        Get.snackbar('Error', 'Failed to save answer: ${saveResponse.statusCode}');
      }
    } else if (response.statusCode == 400) {
      messages.add(BotMessage(message: "Could you please elaborate on: $question"));
    } else {
      Get.snackbar('Error', 'Failed to generate sub-questions');
    }
  }

  Future<void> _handleSubQuestionAnswer(String subQuestion, String answer) async {
    final relevancyResponse = await apiService.checkRelevancy(subQuestion, answer);
    print(':::checkRelevancy::: Status Code: ${relevancyResponse.statusCode}');
    print(':::checkRelevancy::: Response Body: ${relevancyResponse.body}');

    _removeLoadingMessage();

    if (relevancyResponse.statusCode == 200) {
      final saveResponse = await apiService.saveAnswer(
        botController.selectedBookId.value,
        botController.getSelectedSectionId(),
        subQuestion,
        answer,
      );
      print(':::saveAnswer::: Status Code: ${saveResponse.statusCode}');
      print(':::saveAnswer::: Response Body: ${saveResponse.body}');
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
      messages.add(BotMessage(message: "Could you provide a more relevant answer on: $subQuestion"));
    } else {
      Get.snackbar('Error', 'Failed to check relevancy: ${relevancyResponse.statusCode}');
    }
  }

  var hasText = false.obs;

  void updateHasText(String text) {
    hasText.value = text.isNotEmpty;
  }
}