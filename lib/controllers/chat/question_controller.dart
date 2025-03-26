import 'dart:convert';

import 'package:get/get.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/services/database/databaseHelper.dart';

import '../../services/model/bookModel.dart';

class QuestionController extends GetxController {
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  var questions = <Question>[].obs;
  var currentQuestionIndex = 0.obs;
  var subQuestions = <String>[].obs;
  var currentSubQuestionIndex = 0.obs;
  var isSubQuestionMode = false.obs;

  Future<void> fetchQuestions(String sectionId) async {
    print(":::::::::::::::Fetching questions for sectionId: $sectionId");
    questions.value = await dbHelper.getQuestionsForSection(sectionId);
    print(":::::::::::::::::::::Questions from DB: ${questions.map((q) => q.text).toList()}");

    if (questions.isEmpty) {
      final response = await apiService.getQuestionsForSection(sectionId);
      print(':::::::::::::::::::::::: Section ID: $sectionId');
      print(':::::::::::::: Status Code: ${response.statusCode}');
      print('::::::::::::::: Response Body: ${response.body}');

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
        print("Fetched questions: ${fetchedQuestions.map((q) => q.text).toList()}");
        await dbHelper.insertQuestions(fetchedQuestions, sectionId);
      } else {
        Get.snackbar('Error', 'Failed to fetch questions for section $sectionId: ${response.statusCode}');
        print("Failed to fetch questions: ${response.body}");
      }
    }
    // Reset index to ensure we start from the first question
    currentQuestionIndex.value = 0;
    isSubQuestionMode.value = false;
  }

  String getCurrentQuestion() {
    print("Getting current question: index=${currentQuestionIndex.value}, questions.length=${questions.length}, isSubQuestionMode=${isSubQuestionMode.value}");
    if (isSubQuestionMode.value && subQuestions.isNotEmpty) {
      return subQuestions.first;
    }
    if (currentQuestionIndex.value >= questions.length) {
      return 'No more questions';
    }
    return questions[currentQuestionIndex.value].text;
  }

  void nextQuestion() {
    print("Next question: isSubQuestionMode=${isSubQuestionMode.value}, currentSubQuestionIndex=${subQuestions.length > 0 ? 0 : -1}, currentQuestionIndex=${currentQuestionIndex.value}");
    if (isSubQuestionMode.value) {
      subQuestions.removeAt(0);
      if (subQuestions.isEmpty) {
        isSubQuestionMode.value = false;
      }
    } else {
      currentQuestionIndex.value++;
    }
    print("After nextQuestion: currentQuestionIndex=${currentQuestionIndex.value}");
  }

  void setSubQuestions(List<String> newSubQuestions) {
    subQuestions.assignAll(newSubQuestions);
    isSubQuestionMode.value = true;
  }

  void skipToNextUnansweredQuestion(List<Map<String, String>> chatHistory) {
    final answeredQuestions = chatHistory.map((entry) => entry['question']).toList();
    // Reset sub-question mode to ensure we’re checking main questions
    if (isSubQuestionMode.value) {
      isSubQuestionMode.value = false;
      subQuestions.clear();
      currentSubQuestionIndex.value = 0;
    }
    while (currentQuestionIndex.value < questions.length &&
        answeredQuestions.contains(questions[currentQuestionIndex.value].text)) {
      currentQuestionIndex.value++;
    }
    print("Skipped to next unanswered question: index=${currentQuestionIndex.value}");
  }
}