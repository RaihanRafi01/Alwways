import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/services/api_service/api_service.dart';
import 'package:playground_02/services/database/databaseHelper.dart';

import '../../services/model/bookModel.dart';
import '../auth_controller.dart';

class BotController extends GetxController {
  var selectedBookId = ''.obs;
  var selectedSectionId = ''.obs;
  var selectedSectionIndex = (-1).obs; // Index in sections list
  var selectedEpisodeIndex = ''.obs;
  var selectedEpisodeId = ''.obs;

  late final BookController bookController;
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  var sections = <Section>[].obs;

  @override
  void onInit() {
    super.onInit();
    bookController = Get.find<BookController>();
    fetchSections();
  }

  List<Map<String, String>> get books => bookController.books.map((book) => {'id': book.id, 'title': book.title}).toList();

  List<Episode> get episodes => selectedBookId.value.isEmpty
      ? []
      : bookController.books.firstWhere((book) => book.id == selectedBookId.value).episodes;

  Future<void> fetchSections() async {
    print('Fetching sections...');
    sections.value = await dbHelper.getSections();
    final response = await apiService.getSections();
    print('Sections fetch status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final fetchedSections = data.map((json) => Section.fromJson(json)).toList();
      for (var fetchedSection in fetchedSections) {
        final existingSection = sections.firstWhereOrNull((s) => s.id == fetchedSection.id);
        if (existingSection == null || existingSection.updatedAt != fetchedSection.updatedAt) {
          await dbHelper.updateSection(fetchedSection);
        }
      }
      await dbHelper.insertSections(fetchedSections);
      sections.value = await dbHelper.getSections();
      // Log sections for debugging
      print('Fetched sections: ${sections.map((s) => 'ID: ${s.id}, Name: ${s.localizedName}, EpisodeIndex: ${s.episodeIndex}').toList()}');
    }
    else if (response.statusCode == 401){
      final authController = Get.find<AuthController>();
      await authController.logout();
    }
    else {
      print('Failed to fetch sections: ${response.statusCode}');
    }
  }

  void selectBook(String bookId) {
    selectedBookId.value = bookId;
    selectedSectionId.value = '';
    selectedEpisodeId.value = '';
    selectedSectionIndex.value = -1;
    print('Selected book: $bookId');
  }

  void selectSection(String sectionId) {
    selectedSectionId.value = sectionId;
    selectedSectionIndex.value = sections.indexWhere((section) => section.id == sectionId);

    if (selectedSectionIndex.value >= 0 && episodes.isNotEmpty) {
      final section = sections[selectedSectionIndex.value];
      final episodeIndex = section.episodeIndex ?? 0; // Use episodeIndex from section
      if (episodeIndex < episodes.length) {
        selectedEpisodeId.value = episodes[episodeIndex].id;
        selectedEpisodeIndex.value = episodeIndex.toString();
      } else {
        print('Warning: episodeIndex $episodeIndex is out of range for episodes: ${episodes.length}');
        selectedEpisodeId.value = episodes.isNotEmpty ? episodes[0].id : '';
        selectedEpisodeIndex.value = '0';
      }
    } else {
      selectedEpisodeId.value = '';
      selectedEpisodeIndex.value = '';
    }
    print("Selected section: ID=$sectionId, Index=$selectedSectionIndex, EpisodeIndex=$selectedEpisodeIndex, EpisodeID=${selectedEpisodeId.value}");
  }

  Future<List<Map<String, String>>> getChatHistory() async {
    if (selectedEpisodeId.value.isEmpty) return [];
    return await dbHelper.getChatHistory(selectedBookId.value, selectedEpisodeId.value);
  }

  void selectEpisode(String sectionId) {
    selectedSectionId.value = sectionId;
    selectedSectionIndex.value = sections.indexWhere((section) => section.id == sectionId);
    print("Selected section: ID=$sectionId, Index=$selectedSectionIndex");
  }

  String getSelectedSectionId() {
    // Return sectionId instead of index, unless backend specifically needs episodeIndex
    print("Getting selected section: ID=${selectedSectionId.value}, Index=$selectedSectionIndex");
    return selectedSectionId.value;
  }

  RxInt getSectionIndex() {
    // Return sectionId instead of index, unless backend specifically needs episodeIndex
    print("Getting selected section: ID=${selectedSectionId.value}, Index=$selectedSectionIndex");
    return selectedSectionIndex;
  }
}