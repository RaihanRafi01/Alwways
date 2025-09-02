import 'dart:convert';

import 'package:get/get.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/services/database/databaseHelper.dart';

import '../../services/model/bookModel.dart';
import 'botLanding_controller.dart';

class QuestionController extends GetxController {
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final BotController botController = Get.find<BotController>();

  var questions = <Question>[].obs;
  var currentQuestionIndex = 0.obs;
  var subQuestions = <String>[].obs;
  var currentSubQuestionIndex = 0.obs;
  var isSubQuestionMode = false.obs;

  Future<void> fetchQuestions(String sectionId) async {
    print(":::::::::::::::Fetching questions for sectionId: $sectionId");
    questions.value = await dbHelper.getQuestionsForSection(sectionId);
    print(":::::::::::::::::::::Questions from DB: ${questions.map((q) => q.localizedText).toList()}");

    if (questions.isEmpty) {
      final response = await apiService.getQuestionsForSection(sectionId);
      print(':::::::::::::::::::::::: Section ID: $sectionId');
      print(':::::::::::::: Status Code: ${response.statusCode}');
      print('::::::::::::::: Response Body: ${response.body}'); // Log full response

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          print("No questions returned from API for section $sectionId");
        }
        final fetchedQuestions = data.map((json) {
          final question = Question.fromJson(json);
          return Question(
            id: question.id,
            episodeId: '',
            sectionId: sectionId,
            text: question.text,
            v: question.v,
            createdAt: question.createdAt,
            updatedAt: question.updatedAt,
          );
        }).toList();
        questions.value = fetchedQuestions;
        print("Fetched questions: ${fetchedQuestions.map((q) => q.localizedText).toList()}");
        await dbHelper.insertQuestions(fetchedQuestions, sectionId);
      } else {
        print("Failed to fetch questions: ${response.body}");
      }
    }
    currentQuestionIndex.value = 0;
    isSubQuestionMode.value = false;
  }

  Future<void> nextQuestion() async {
    print("Next question: isSubQuestionMode=${isSubQuestionMode.value}, "
        "currentSubQuestionIndex=${currentSubQuestionIndex.value}, "
        "currentQuestionIndex=${currentQuestionIndex.value}");

    if (isSubQuestionMode.value) {
      currentSubQuestionIndex.value++;
      if (currentSubQuestionIndex.value >= subQuestions.length) {
        // Sub-questions finished, switch back to main questions
        isSubQuestionMode.value = false;
        currentSubQuestionIndex.value = 0;
        subQuestions.clear();
        currentQuestionIndex.value++; // Move to next main question
      }
    } else {
      currentQuestionIndex.value++;
    }

    // Fetch chat history to check answered questions
    final bookId = botController.selectedBookId.value;
    final episodeId = botController.selectedEpisodeId.value;
    final history = await dbHelper.getChatHistory(bookId, episodeId);

    // Skip to the next unanswered question
    while (currentQuestionIndex.value < questions.length) {
      final currentQuestionText = questions[currentQuestionIndex.value].localizedText;
      if (!history.any((entry) => entry['question'] == currentQuestionText)) {
        print("Skipped to next unanswered question: index=${currentQuestionIndex.value}");
        break;
      }
      currentQuestionIndex.value++;
    }

    if (currentQuestionIndex.value >= questions.length) {
      print("All main questions answered");
    }

    print("After nextQuestion: currentQuestionIndex=${currentQuestionIndex.value}");
  }

  String getCurrentQuestion() {
    print("Getting current question: index=${currentQuestionIndex.value}, "
        "questions.length=${questions.length}, isSubQuestionMode=${isSubQuestionMode.value}");
    if (isSubQuestionMode.value && subQuestions.isNotEmpty) {
      return subQuestions[currentSubQuestionIndex.value];
    }
    if (currentQuestionIndex.value >= questions.length) {
      return 'No more questions';
    }
    return questions[currentQuestionIndex.value].localizedText;
  }

  void setSubQuestions(List<String> newSubQuestions) {
    subQuestions.assignAll(newSubQuestions);
    isSubQuestionMode.value = true;
  }

  void skipToNextUnansweredQuestion(List<Map<String, String>> chatHistory) {
    final answeredQuestions = chatHistory.map((entry) => entry['question']).toList();

    // Reset sub-question mode initially
    isSubQuestionMode.value = false;
    subQuestions.clear();
    currentSubQuestionIndex.value = 0;

    // Check if we were in sub-question mode by looking at the last history entry
    if (chatHistory.isNotEmpty) {
      final lastQuestion = chatHistory.last['question']!;
      final lastMainQuestionIndex = questions.indexWhere((q) => q.localizedText == lastQuestion);

      if (lastMainQuestionIndex == -1) {
        // Last question was a sub-question; find the parent main question
        final parentQuestionIndex = currentQuestionIndex.value; // Assume current index as parent
        if (parentQuestionIndex < questions.length) {
          // Fetch sub-questions for the last main question (simplified; ideally fetch from API or history)
          // For now, assume sub-questions are still in memory or need to be refetched
          // This requires storing sub-questions in DB or passing them via navigation
        }
      } else {
        currentQuestionIndex.value = lastMainQuestionIndex;
      }
    }

    // Skip to the next unanswered main question
    while (currentQuestionIndex.value < questions.length &&
        answeredQuestions.contains(questions[currentQuestionIndex.value].localizedText)) {
      currentQuestionIndex.value++;
    }

    print("Skipped to next unanswered question: index=${currentQuestionIndex.value}");
  }
}