import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/controllers/chat/question_controller.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/services/database/databaseHelper.dart';
import 'package:playground_02/widgets/chat/userMessage.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';
import '../../services/model/bookModel.dart';
import '../../views/chatWithAI/chatScreen.dart';
import '../../views/home/home_landing.dart';
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
      final lang = Get.locale?.languageCode ?? 'en';
      questionController.questions.value = [
        Question(
          id: "1",
          episodeId: '',
          sectionId: 'initial',
          text: {lang: "question_1".tr}, // e.g., "Who is this book for?"
          v: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        // Other initial questions updated similarly
      ];
    }
  }

  Future<void> fetchQuestionsAndLoadHistory(String sectionId) async {
    this.sectionId = sectionId;
    await questionController.fetchQuestions(sectionId);
    final bookId = botController.selectedBookId.value;
    final episodeId = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeId);
    print("Chat history for bookId: $bookId, episodeId: $episodeId, sectionId: $sectionId: $history");

    messages.clear();
    userAnswers.clear();

    // Rebuild conversation from history
    for (var entry in history) {
      messages.add(BotMessage(message: entry['question']!));
      messages.add(UserMessage(message: entry['answer']!));
      userAnswers.add({'question': entry['question']!, 'answer': entry['answer']!});
    }

    // Restore last state
    if (history.isNotEmpty) {
      final lastQuestion = history.last['question']!;
      final lastMainQuestionIndex = questionController.questions.indexWhere((q) => q.localizedText == lastQuestion);

      if (lastMainQuestionIndex != -1) {
        // Last question was a main question
        questionController.currentQuestionIndex.value = lastMainQuestionIndex;
        questionController.isSubQuestionMode.value = false;
        questionController.subQuestions.clear();
        questionController.currentSubQuestionIndex.value = 0;
      } else {
        // Last question was a sub-question; find parent and restore sub-question state
        // This requires sub-questions to be persisted or refetched
        // For now, find the last main question and assume sub-questions need refetching
        final parentQuestionIndex = questionController.questions.indexWhere((q) => history.any((h) => h['question'] == q.localizedText));
        if (parentQuestionIndex != -1) {
          questionController.currentQuestionIndex.value = parentQuestionIndex;
          // Simulate fetching sub-questions (replace with actual API call if needed)
          final lastMainQuestion = questionController.questions[parentQuestionIndex].localizedText;
          final lastAnswer = history.lastWhere((h) => h['question'] == lastMainQuestion, orElse: () => {'answer': ''})['answer']!;
          final response = await apiService.generateSubQuestion(lastMainQuestion, lastAnswer);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final subQuestions = List<String>.from(data['content']);
            questionController.subQuestions.value = subQuestions;
            questionController.isSubQuestionMode.value = true;
            questionController.currentSubQuestionIndex.value = subQuestions.indexOf(lastQuestion) + 1;
            if (questionController.currentSubQuestionIndex.value >= subQuestions.length) {
              questionController.isSubQuestionMode.value = false;
              questionController.subQuestions.clear();
              questionController.currentSubQuestionIndex.value = 0;
              questionController.currentQuestionIndex.value++;
            }
          }
        }
      }
    }

    // Skip to next unanswered question
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
      print("In initial chat mode, checking relevancy...");
      _showLoadingMessage();

      final response = await apiService.checkRelevancy(currentQuestion, userAnswer);
      print("Relevancy check - Status Code: ${response.statusCode}, Body: ${response.body}");

      _removeLoadingMessage();

      if (response.statusCode == 400) {
        messages.add(BotMessage(message: "Could you provide a more relevant answer to: $currentQuestion"));
      } else {
        if (questionController.currentQuestionIndex.value == 0 && userAnswers.length == 1) {
          String lowerAnswer = userAnswer.toLowerCase();
          print("::: Debugging isForSelf ::: lowerAnswer: '$lowerAnswer'");

          bool isForSelf = (lowerAnswer.contains(" me ") || // "me" as a standalone word
              lowerAnswer.contains("myself") ||
              lowerAnswer.contains("i ") || // Already has a space
              lowerAnswer.contains("my own") ||
              lowerAnswer.contains("for me") ||
              lowerAnswer.contains("mine") ||
              lowerAnswer.contains("my book") ||
              lowerAnswer.contains("personal") ||
              lowerAnswer.contains("self") ||
              lowerAnswer.contains("i am") ||
              lowerAnswer.contains("i'm") ||
              lowerAnswer.contains("for myself") ||
              lowerAnswer.contains("by me") ||
              lowerAnswer.contains("about me") ||
              lowerAnswer.contains("on me") ||
              lowerAnswer.contains("i want") ||
              lowerAnswer.contains("i will") ||
              lowerAnswer.contains("i'll") ||
              lowerAnswer.contains("my story") ||
              lowerAnswer.contains("my life") ||
              lowerAnswer.contains("me personally") ||
              lowerAnswer.contains("to me") ||
              lowerAnswer.contains("i need") ||
              lowerAnswer.contains("i think") ||
              lowerAnswer.contains("my memoir") ||
              lowerAnswer.contains("i wrote") ||
              lowerAnswer.contains("written by me") ||
              lowerAnswer.contains("my personal") ||
              lowerAnswer.contains("me alone") ||
              lowerAnswer.contains("just me") ||
              lowerAnswer.contains("only me") ||
              lowerAnswer.contains("i myself") ||
              lowerAnswer.contains("me too") ||
              lowerAnswer.contains("my journey") ||
              lowerAnswer.contains("i intend")) &&
              !lowerAnswer.contains("someone") && // Explicitly exclude "someone"
              !lowerAnswer.contains("someone else");

          print("::: Debugging isForSelf ::: isForSelf: $isForSelf");
          final lang = Get.locale?.languageCode ?? 'en';

          if (isForSelf) {
            questionController.questions.value = [
              Question(
                id: "2",
                episodeId: '',
                sectionId: 'initial',
                text: {lang: "question_2".tr}, // "What is your name?"
                v: 0,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
              Question(
                id: "3",
                episodeId: '',
                sectionId: 'initial',
                text: {lang: "question_3".tr}, // "What title would you like to give the book? ..."
                v: 0,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
            ];
            print("::: Set questions for self ::: ['What is your name?', 'What title ...']");
          } else {
            questionController.questions.value = [
              Question(
                id: "2",
                episodeId: '',
                sectionId: 'initial',
                text: {lang: "question_2_1".tr}, // "What is their name?"
                v: 0,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
              Question(
                id: "3",
                episodeId: '',
                sectionId: 'initial',
                text: {lang: "question_3".tr}, // "What title would you like to give the book? ..."
                v: 0,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
            ];
            print("::: Set questions for other ::: ['What is their name?', 'What title ...']");
          }
          questionController.currentQuestionIndex.value = 0;
          askQuestion();
        } else {
          questionController.nextQuestion();
          if (questionController.currentQuestionIndex.value < questionController.questions.length) {
            askQuestion();
          } else {
            print("All initial questions answered, proceeding to create book...");
            _createBookAndNavigate();
          }
        }
      }
      return;
    }

    // Existing code for when a book is selected...
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
          (a) => a['question'] == 'What title would you like to give the book? Don\'t worry, you can change it anytime.',
      orElse: () => {'answer': 'My Memoir'},
    )['answer'] ?? 'My Memoir';
    bookController.bookNameController.text = bookName;

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
      barrierDismissible: false,
    );

    try {
      print("Calling createBook()...");
      await bookController.createBook();

      print("Books after creation: ${botController.books.length}, Sections: ${botController.sections.length}");
      if (botController.books.isEmpty || botController.sections.isEmpty) {
        throw Exception("Failed to initialize book or sections");
      }

      String newBookId = botController.books.first['id']!;
      String firstSectionId = botController.sections.first.id;
      Book newBook = bookController.books.firstWhere((b) => b.id == newBookId);
      String firstEpisodeId = newBook.episodes.isNotEmpty ? newBook.episodes.first.id : '';

      if (firstEpisodeId.isEmpty) {
        throw Exception("No episodes found for new book");
      }

      print("::::::::::::::: GGG ::::::::::::::::::::::: book id : $newBookId , sectionId : $firstSectionId , episodeId : $firstEpisodeId");

      botController.selectBook(newBookId);
      botController.selectSection(firstSectionId);
      botController.selectedEpisodeId.value = firstEpisodeId;
      print("Selected section: $firstSectionId, episode: $firstEpisodeId");

      sectionId = firstSectionId;
      await fetchQuestionsAndLoadHistory(firstSectionId);

      print("Waiting 3 seconds before navigation...");
      await Future.delayed(const Duration(seconds: 3));

      print("Navigating to HomePageLanding...");
      Get.back(); // Close the loading dialog
      Get.to(() => HomePageLanding(
        bookId: newBookId,
        bookTitle: bookName,
        coverImage: bookController.getCoverImage(newBookId, 'assets/images/book/cover_image_1.svg'),
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
      print("Error: No section found for sectionId: $sectionId  Error :::::::::::::::::::::::: $e");
      Get.snackbar('Error', 'Section not found for ID: $sectionId');
      return;
    }

    final totalQuestions = currentSection.questionsCount;
    final bookId = botController.selectedBookId.value;
    final episodeId = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeId);

    final mainQuestions = questionController.questions.map((q) => q.localizedText).toList();
    final uniqueAnsweredQuestions = history
        .where((entry) => mainQuestions.contains(entry['question']))
        .map((entry) => entry['question'])
        .toSet()
        .toList();
    final answeredMainQuestions = uniqueAnsweredQuestions.length;

    final completionPercentage = totalQuestions > 0 ? (answeredMainQuestions / totalQuestions) * 100 : 0;
    print("Section: ${currentSection.localizedName}, Total: $totalQuestions, Answered: $answeredMainQuestions, Completion: ${completionPercentage.toStringAsFixed(2)}%");

    final episodeIndex = botController.selectedSectionIndex.toString() ?? '0'; // Use section's episodeIndex
    print("::::::::::::::::::::::Selected section index: $episodeIndex");
    try {
      final response = await apiService.updateEpisodePercentage(bookId, episodeIndex, completionPercentage);
      print(":::updateEpisodePercentage::: Status Code: ${response.statusCode}");
      print(":::updateEpisodePercentage::: Response Body: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final db = await dbHelper.database;
        final episodeMaps = await db.query(
          'episodes',
          where: 'bookId = ? AND id = ?',
          whereArgs: [bookId, episodeId],
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
            question, // Already localized from getCurrentQuestion
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
        _removeLoadingMessage();
        messages.add(BotMessage(message: "Could you please elaborate on: $question"));
      } else {
        Get.snackbar('Error', 'Failed to generate sub-questions');
      }
    }

    Future<void> _handleSubQuestionAnswer(String subQuestion, String answer) async {
      final relevancyResponse = await apiService.checkRelevancy(subQuestion, answer);
      print(':::checkRelevancy::: Status Code: ${relevancyResponse.statusCode}');
      print(':::checkRelevancy::: Response Body: ${relevancyResponse.body}');

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
        _removeLoadingMessage();
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