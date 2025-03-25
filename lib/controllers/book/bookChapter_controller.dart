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

  final RxList<String> allPages = <String>[].obs;
  final RxList<String> allPageChapters = <String>[].obs;
  final RxList<String?> allPageImages = <String?>[].obs;
  final RxList<String> pageConversationIds = <String>[].obs;
  final RxString story = ''.obs;
  final RxBool usingConversations = false.obs;
  final RxBool isLoading = true.obs;

  String? bookId;
  String? episodeId;

  @override
  void onInit() {
    super.onInit();
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

  Future<void> loadStory(String bookId, String episodeIndex, String episodeCoverImage) async {
    this.bookId = bookId;
    print("Starting loadStory for bookId: $bookId, episodeIndex: $episodeIndex");
    isLoading.value = true;

    try {
      final book = bookController.books.firstWhere(
            (b) => b.id == bookId,
        orElse: () => throw Exception("Book not found: $bookId"),
      );
      print("Book found: ${book.title}");

      final episodes = book.episodes;
      final index = int.parse(episodeIndex);
      if (index < 0 || index >= episodes.length) {
        throw Exception("Invalid episode index: $episodeIndex");
      }
      episodeId = episodes[index].id;
      print("Episode loaded: ${episodes[index].title}");

      final db = await dbHelper.database;
      final episodeMaps = await db.query(
        'episodes',
        where: 'bookId = ? AND id = ?',
        whereArgs: [bookId, episodeId],
      );

      Episode episode;
      if (episodeMaps.isNotEmpty) {
        episode = Episode.fromMap(episodeMaps.first);
      } else {
        episode = episodes[index];
      }

      allPages.clear();
      allPageChapters.clear();
      allPageImages.clear();
      pageConversationIds.clear();
      allPageImages.add(episodeCoverImage);

      final storyConversations = episode.conversations.where((c) => c['storyGenerated'] == true).toList();
      print("Found ${storyConversations.length} story conversations");

      if (storyConversations.isNotEmpty) {
        usingConversations.value = true;
        final combinedStory = storyConversations.map((c) => c['botResponse'] as String).join(' ');
        story.value = combinedStory;
        print("Combined botResponses: ${story.value.substring(0, story.value.length < 50 ? story.value.length : 50)}...");
        _splitContentIntoPages(convoId: storyConversations.first['_id']);
      } else {
        usingConversations.value = false;
        if (episode.story != null && episode.story!.isNotEmpty) {
          story.value = episode.story!;
          print("Story field found: ${story.value.substring(0, story.value.length < 50 ? story.value.length : 50)}...");
          _splitContentIntoPages();
        } else {
          print("No story field, fetching from API");
          final response = await apiService.generateStory(bookId, episodeIndex);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            story.value = data['story'];
            print("Story fetched: ${story.value.substring(0, story.value.length < 50 ? story.value.length : 50)}...");
            _splitContentIntoPages();

            final updatedEpisode = episode.copyWith(story: story.value);
            if (episodeMaps.isEmpty) {
              await dbHelper.insertEpisode(updatedEpisode);
            } else {
              await dbHelper.updateEpisode(updatedEpisode);
            }
            print("Fetched and saved story from API for episode $episodeId");
          } else {
            Get.snackbar('Error', 'Failed to generate story: ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      print("Error in loadStory: $e");
      Get.snackbar('Error', 'Failed to load story: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _splitContentIntoPages({String? convoId}) {
    allPages.clear();
    allPageChapters.clear();
    pageConversationIds.clear();
    while (allPageImages.length > 1) {
      allPageImages.removeLast();
    }

    if (story.value.isEmpty) {
      print("Story is empty, no pages created.");
      allPages.add("No story content available");
      allPageChapters.add("Part 1");
      pageConversationIds.add(convoId ?? '');
      allPageImages.add(null);
      return;
    }

    const int wordsPerPage = 50;
    List<String> words = story.value.split(' ');
    print("Total words in story: ${words.length}");

    for (var i = 0; i < words.length; i += wordsPerPage) {
      final pageWords = words.sublist(
        i,
        i + wordsPerPage < words.length ? i + wordsPerPage : words.length,
      );
      allPages.add(pageWords.join(' '));
      allPageChapters.add("Part ${allPages.length}");
      pageConversationIds.add(convoId ?? '');
      allPageImages.add(null);
    }
    print("Split into ${allPages.length} pages with $wordsPerPage words per page");
    print("allPages.length: ${allPages.length}, allPageChapters.length: ${allPageChapters.length}, allPageImages.length: ${allPageImages.length}");
  }

  Future<void> updateChapterContent(int index, String newContent) async {
    if (index < 0 || index >= allPages.length) {
      throw Exception("Invalid page index");
    }
    // Safely log new content, avoiding RangeError
    final previewLength = newContent.length < 60 ? newContent.length : 60;
    print("Updating page $index with new content: ${newContent.substring(0, previewLength)}...");

    // Update the specific page locally
    allPages[index] = newContent;

    final conversationId = pageConversationIds[index];
    if (conversationId.isNotEmpty) {
      // Update full story via API to preserve other pages
      final apiData = {'botResponse': allPages.join(' ')};
      try {
        final response = await apiService.updateConversation(bookId!, episodeId!, conversationId, apiData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await updateDatabaseStory();
          print("Successfully updated content for page $index via API");
        } else {
          Get.snackbar('Error', 'Failed to update server: ${response.body}');
          // Revert on failure (optional: store old content if needed)
        }
      } catch (e) {
        Get.snackbar('Error', 'API call error: $e');
      }
    } else {
      // Local update only
      await updateDatabaseStory();
      print("Updated content locally for page $index");
    }
  }

  Future<void> updateChapterTitle(int index, String newTitle) async {
    if (index < 0 || index >= allPageChapters.length) {
      throw Exception("Invalid chapter index");
    }
    allPageChapters[index] = newTitle;
    await updateDatabaseStory();
    print("Updated title for page $index to: $newTitle");
  }

  void updateChapterImage(int index, String? imagePath) {
    if (index < 0 || index >= allPageImages.length) {
      throw Exception("Invalid chapter index");
    }
    allPageImages[index] = imagePath;
    print("Updated image for page $index to: $imagePath");
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
      if (usingConversations.value) {
        final updatedConversations = List.from(episode.conversations);
        final combinedStory = allPages.join(' ');
        final convoIndex = updatedConversations.indexWhere((c) => c['_id'] == pageConversationIds.first);
        if (convoIndex != -1) {
          updatedConversations[convoIndex]['botResponse'] = combinedStory;
        }
        final updatedEpisode = episode.copyWith(conversations: updatedConversations);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated conversations in database for episode $episodeId");
      } else {
        final updatedStory = allPages.join(' ');
        final updatedEpisode = episode.copyWith(story: updatedStory);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated story in database for episode $episodeId: ${updatedStory.substring(0, updatedStory.length < 50 ? updatedStory.length : 50)}...");
      }
    }
  }

  String regenerateStory(List<dynamic> conversations) {
    if (conversations.isEmpty) {
      return allPages.join(' ');
    }
    final storyParts = conversations
        .where((c) => c['storyGenerated'] == true)
        .map((c) => c['botResponse'] as String)
        .toList();
    return storyParts.join(' ');
  }
}