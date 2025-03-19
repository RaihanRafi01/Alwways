import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service/api_service.dart';
import '../../services/database/databaseHelper.dart';
import '../../services/model/bookModel.dart';
import 'bookLanding_controller.dart';

class BookChapterController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final BookLandingController bookController = Get.find<BookLandingController>();

  final RxList<String> bookChapters = ["Landing"].obs;
  final RxList<String> bookContents = ["Landing"].obs;

  late RxList<String?> bookImages = List<String?>.filled(bookContents.length, null).obs;
  final RxString story = ''.obs;

  final RxList<String> allPages = <String>[].obs;
  final RxList<String> allPageChapters = <String>[].obs;
  final RxList<String?> allPageImages = <String?>[].obs;

  String? bookId;
  String? episodeId;

  @override
  void onInit() {
    super.onInit();
    _splitContentIntoPages();
    pageController.addListener(_onPageChanged);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.onClose();
  }

  void _onPageChanged() {
    final pageIndex = pageController.page?.round() ?? 0;
    if (currentPage.value != pageIndex) {
      currentPage.value = pageIndex;
    }
  }

  void _splitContentIntoPages({int maxWordsPerPage = 120}) {
    allPages.clear();
    allPageChapters.clear();
    allPageImages.clear();

    // Split book contents
    for (var i = 0; i < bookContents.length; i++) {
      final content = bookContents[i];
      final chapterTitle = bookChapters[i];
      final chapterImage = bookImages[i];

      final words = content.split(' ');
      for (var j = 0; j < words.length; j += maxWordsPerPage) {
        final page = words
            .sublist(j, (j + maxWordsPerPage).clamp(0, words.length))
            .join(' ');
        allPages.add(page);
        allPageChapters.add(chapterTitle);
        allPageImages.add(chapterImage);
      }
    }

    // Split story content if it exists
    if (story.value.isNotEmpty) {
      final storyWords = story.value.split(' ');
      for (var i = 0; i < storyWords.length; i += maxWordsPerPage) {
        final page = storyWords
            .sublist(i, (i + maxWordsPerPage).clamp(0, storyWords.length))
            .join(' ');
        allPages.add(page);
        allPageChapters.add("Story Part ${i ~/ maxWordsPerPage + 1}");
        allPageImages.add(null);
      }
    }
  }

  Future<void> loadStory(String bookId, String episodeIndex) async {
    this.bookId = bookId;

    // Convert episodeIndex to actual Episode.id
    final book = bookController.books.firstWhere(
          (b) => b.id == bookId,
      orElse: () => throw Exception("Book not found: $bookId"),
    );
    final episodes = book.episodes;
    final index = int.parse(episodeIndex);
    if (index < 0 || index >= episodes.length) {
      throw Exception("Invalid episode index: $episodeIndex");
    }
    episodeId = episodes[index].id;

    // Check database for existing story
    final db = await dbHelper.database;
    final episodeMaps = await db.query(
      'episodes',
      where: 'bookId = ? AND id = ?',
      whereArgs: [bookId, episodeId],
    );

    if (episodeMaps.isNotEmpty) {
      final episode = Episode.fromMap(episodeMaps.first);
      if (episode.story != null && episode.story!.isNotEmpty) {
        story.value = episode.story!;
        _splitContentIntoPages();
        print("Loaded story from database for episode $episodeId: ${story.value}");
        return;
      }
    }

    // Fetch from API if no story in database
    try {
      final response = await apiService.generateStory(bookId, episodeIndex);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        story.value = data['story'];
        _splitContentIntoPages();
        print("Fetched story from API for episode $episodeId (index $episodeIndex): ${story.value}");

        // Save or update story in database
        final episode = episodes[index];
        final newEpisode = Episode(
          id: episodeId!,
          bookId: bookId,
          title: episode.title,
          coverImage: episode.coverImage,
          percentage: episode.percentage,
          conversations: episode.conversations,
          story: story.value,
        );

        if (episodeMaps.isNotEmpty) {
          await dbHelper.updateEpisode(newEpisode);
          print("Updated story in database for episode $episodeId");
        } else {
          await dbHelper.insertEpisode(newEpisode);
          print("Inserted new episode $episodeId with story into database");
        }
      } else {
        Get.snackbar('Error', 'Failed to generate story: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching story: $e");
      Get.snackbar('Error', 'Failed to fetch story: $e');
    }
  }

  void updateChapterTitle(int index, String newTitle) {
    if (index < 0 || index >= allPageChapters.length) {
      throw Exception("Invalid chapter index");
    }
    allPageChapters[index] = newTitle;
    if (index < bookChapters.length) {
      bookChapters[index] = newTitle;
    }
    _splitContentIntoPages();
    updateDatabaseStory();
  }

  void updateChapterContent(int index, String newContent) {
    if (index < 0 || index >= allPages.length) {
      throw Exception("Invalid page index");
    }
    allPages[index] = newContent;
    if (index < bookContents.length) {
      bookContents[index] = newContent;
    }
    _splitContentIntoPages();
    updateDatabaseStory();
  }

  void updateChapterImage(int index, String? imagePath) {
    if (index < 0 || index >= allPageImages.length) {
      throw Exception("Invalid chapter index");
    }
    allPageImages[index] = imagePath;
    if (index < bookImages.length) {
      bookImages[index] = imagePath;
    }
    _splitContentIntoPages();
  }

  Future<void> updateDatabaseStory() async {
    if (bookId == null || episodeId == null) return;

    final db = await dbHelper.database;
    final episodeMaps = await db.query(
      'episodes',
      where: 'bookId = ? AND id = ?',
      whereArgs: [bookId, episodeId],
    );

    if (episodeMaps.isNotEmpty) {
      final episode = Episode.fromMap(episodeMaps.first);
      final updatedStory = allPages.join('\n\n');
      final updatedEpisode = episode.copyWith(story: updatedStory);
      await dbHelper.updateEpisode(updatedEpisode);
      print("Updated story in database for episode $episodeId: $updatedStory");
    }
  }
}