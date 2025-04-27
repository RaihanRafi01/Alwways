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
      // Find the book
      final book = bookController.books.firstWhere(
            (b) => b.id == bookId,
        orElse: () => throw Exception("Book not found: $bookId"),
      );
      print("Book found: ${book.title}");

      // Validate episode index and set episodeId
      final episodes = book.episodes;
      final index = int.parse(episodeIndex);
      if (index < 0 || index >= episodes.length) {
        throw Exception("Invalid episode index: $episodeIndex");
      }
      episodeId = episodes[index].id;
      print("Episode loaded: ${episodes[index].title}");

      // Fetch episode from database or use the one from book
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

      // Reset all lists to ensure clean state
      allPages.clear();
      allPageChapters.clear();
      allPageImages.clear();
      pageConversationIds.clear();

      // Add the episode cover image as the first image
      allPageImages.add(episodeCoverImage);

      // Fetch sections (assuming they relate to the episode)
      final sections = await dbHelper.getSections();
      print("Fetched ${sections.length} sections");

      // Check for story conversations
      final storyConversations = episode.conversations.where((c) => c['storyGenerated'] == true).toList();
      print("Found ${storyConversations.length} story conversations");

      if (storyConversations.isNotEmpty) {
        usingConversations.value = true;
        // Each conversation is a separate page
        allPages.value = storyConversations.map((c) => c['botResponse'] as String).toList();
        pageConversationIds.value = storyConversations.map((c) => c['_id'] as String).toList();
        // Assign chapter titles based on sections or fallback to numbered chapters
        if (sections.length == storyConversations.length) {
          allPageChapters.value = sections.map((s) => s.localizedName).toList();
        } else {
          allPageChapters.value = List.generate(allPages.length, (i) => "Chapter ${i + 1}");
        }
        // Initialize images for all pages (excluding the cover image already added)
        allPageImages.addAll(List<String?>.filled(allPages.length, null));
        print("Loaded ${allPages.length} pages from conversations");
      } else {
        usingConversations.value = false;
        if (episode.story != null && episode.story!.isNotEmpty) {
          story.value = episode.story!;
          _splitStoryContent(sections);
        } else {
          print("No story field, fetching from API");
          final response = await apiService.generateStory(bookId, episodeIndex);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            story.value = data['story'];
            print("Story fetched: ${story.value.substring(0, story.value.length < 50 ? story.value.length : 50)}...");
            _splitStoryContent(sections);

            final updatedEpisode = episode.copyWith(story: story.value);
            if (episodeMaps.isEmpty) {
              await dbHelper.insertEpisode(updatedEpisode);
            } else {
              await dbHelper.updateEpisode(updatedEpisode);
            }
            print("Fetched and saved story from API for episode $episodeId");
          } else {
            throw Exception("Failed to generate story: ${response.statusCode}");
          }
        }
      }

      // Reset page controller to the first page
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
      currentPage.value = 0;
    } catch (e) {
      print("Error in loadStory: $e");
      Get.snackbar('Error', 'Failed to load story: $e');
      // Set fallback content
      allPages.clear();
      allPageChapters.clear();
      allPageImages.clear();
      pageConversationIds.clear();
      allPages.add("Error loading story");
      allPageChapters.add("Error");
      allPageImages.add(null);
      pageConversationIds.add('');
    } finally {
      isLoading.value = false;
    }
  }

  void _splitStoryContent(List<Section> sections) {
    if (story.value.isEmpty) {
      allPages.add("No story content available");
      allPageChapters.add("Part 1");
      pageConversationIds.add('');
      allPageImages.add(null);
      return;
    }

    if (sections.isNotEmpty) {
      // Split story into equal parts based on number of sections
      final partLength = (story.value.length / sections.length).ceil();
      allPages.value = List.generate(sections.length, (index) {
        final start = index * partLength;
        final end = (index + 1) * partLength < story.value.length ? (index + 1) * partLength : story.value.length;
        return story.value.substring(start, end);
      });
      allPageChapters.value = sections.map((s) => s.localizedName).toList();
      pageConversationIds.value = List.filled(sections.length, '');
      allPageImages.addAll(List<String?>.filled(sections.length, null));
    } else {
      // Fallback to fixed-size pages
      const int wordsPerPage = 50;
      List<String> words = story.value.split(' ');
      for (var i = 0; i < words.length; i += wordsPerPage) {
        final pageWords = words.sublist(
          i,
          i + wordsPerPage < words.length ? i + wordsPerPage : words.length,
        );
        allPages.add(pageWords.join(' '));
        allPageChapters.add("Part ${allPages.length}");
        pageConversationIds.add('');
        allPageImages.add(null);
      }
    }
    print("Split story into ${allPages.length} pages");
  }

  Future<void> updateChapterContent(int index, String newContent) async {
    if (index < 0 || index >= allPages.length) {
      throw Exception("Invalid page index: $index");
    }
    print("Updating page $index with new content: ${newContent.substring(0, newContent.length < 60 ? newContent.length : 60)}...");

    allPages[index] = newContent;

    final conversationId = pageConversationIds[index];
    if (usingConversations.value && conversationId.isNotEmpty) {
      // Update specific conversation via API
      final apiData = {'botResponse': newContent};
      try {
        final response = await apiService.updateConversation(bookId!, episodeId!, conversationId, apiData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await updateDatabaseStory();
          print("Successfully updated content for page $index via API");
        } else {
          Get.snackbar('Error', 'Failed to update server: ${response.body}');
        }
      } catch (e) {
        Get.snackbar('Error', 'API call error: $e');
      }
    } else {
      // Update story field locally
      await updateDatabaseStory();
      print("Updated content locally for page $index");
    }
  }

  Future<void> updateChapterTitle(int index, String newTitle) async {
    if (index < 0 || index >= allPageChapters.length) {
      throw Exception("Invalid chapter index: $index");
    }
    allPageChapters[index] = newTitle;
    print("Updated title for page $index to: $newTitle");
    // Note: Titles are not persisted in the database in this implementation
  }

  void updateChapterImage(int index, String? imagePath) {
    if (index < 0 || index >= allPageImages.length) {
      throw Exception("Invalid chapter index: $index");
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
        for (int i = 0; i < allPages.length; i++) {
          final convoId = pageConversationIds[i];
          final convoIndex = updatedConversations.indexWhere((c) => c['_id'] == convoId);
          if (convoIndex != -1) {
            updatedConversations[convoIndex]['botResponse'] = allPages[i];
          }
        }
        final updatedEpisode = episode.copyWith(conversations: updatedConversations);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated conversations in database for episode $episodeId");
      } else {
        final updatedStory = allPages.join(' ');
        final updatedEpisode = episode.copyWith(story: updatedStory);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated story in database for episode $episodeId");
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