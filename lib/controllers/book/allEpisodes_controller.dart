import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service/api_service.dart';
import '../../services/database/databaseHelper.dart';
import '../../services/model/bookModel.dart';

class AllEpisodesController extends GetxController {
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final PageController pageController = PageController();

  // Store episodes
  final RxList<Episode> episodes = <Episode>[].obs;

  // Store pages, chapters, images, and conversation IDs for each episode
  final RxList<List<String>> allPages = <List<String>>[].obs;
  final RxList<List<String>> allPageChapters = <List<String>>[].obs;
  final RxList<List<String?>> allPageImages = <List<String?>>[].obs;
  final RxList<List<String>> pageConversationIds = <List<String>>[].obs;

  // Flattened list of all pages for PageView
  final RxList<Map<String, dynamic>> flatPages = <Map<String, dynamic>>[].obs;

  final RxBool usingConversations = false.obs;
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 0.obs; // Added to track current page

  String? bookId;
  String? bookTitle;
  String? bookCoverImage;

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
    currentPage.value = pageController.page?.round() ?? 0;
  }

  Future<void> loadAllEpisodes(String bookId, String bookTitle, String bookCoverImage) async {
    this.bookId = bookId;
    this.bookTitle = bookTitle;
    this.bookCoverImage = bookCoverImage;
    print("Starting loadAllEpisodes for bookId: $bookId, title: $bookTitle");
    isLoading.value = true;

    try {
      // Fetch book and episodes
      final books = await dbHelper.getBooks();
      final book = books.firstWhere(
            (b) => b.id == bookId,
        orElse: () => throw Exception("Book not found: $bookId"),
      );
      print("Book found: ${book.title}");

      // Load episodes
      episodes.value = book.episodes;
      print("Loaded ${episodes.length} episodes");

      // Initialize lists for each episode
      allPages.value = List.generate(episodes.length, (_) => <String>[]);
      allPageChapters.value = List.generate(episodes.length, (_) => <String>[]);
      allPageImages.value = List.generate(episodes.length, (_) => <String?>[]);
      pageConversationIds.value = List.generate(episodes.length, (_) => <String>[]);

      // Load content for each episode
      for (var episodeIndex = 0; episodeIndex < episodes.length; episodeIndex++) {
        await _loadEpisodeContent(episodeIndex);
      }

      // Flatten pages for PageView
      _flattenPages();
    } catch (e) {
      print("Error in loadAllEpisodes: $e");
      Get.snackbar('Error', 'Failed to load episodes: $e');
      flatPages.add({'type': 'error', 'message': 'Error loading content'});
    } finally {
      isLoading.value = false;
    }
  }

  void _flattenPages() {
    flatPages.clear();
    // Add book cover page
    flatPages.add({'type': 'book_cover'});

    // Add episode pages
    for (var episodeIndex = 0; episodeIndex < episodes.length; episodeIndex++) {
      // Episode cover
      flatPages.add({
        'type': 'episode_cover',
        'episodeIndex': episodeIndex,
      });
      // Story pages
      for (var pageIndex = 0; pageIndex < allPages[episodeIndex].length; pageIndex++) {
        flatPages.add({
          'type': 'story',
          'episodeIndex': episodeIndex,
          'pageIndex': pageIndex,
        });
      }
    }
    print("Flattened ${flatPages.length} pages for PageView");
  }

  Future<void> _loadEpisodeContent(int episodeIndex) async {
    final episode = episodes[episodeIndex];
    final episodeId = episode.id;
    print("Loading content for episode $episodeId at index $episodeIndex");

    try {
      // Fetch episode from database
      final db = await dbHelper.database;
      final episodeMaps = await db.query(
        'episodes',
        where: 'bookId = ? AND id = ?',
        whereArgs: [bookId, episodeId],
      );

      Episode updatedEpisode;
      if (episodeMaps.isNotEmpty) {
        updatedEpisode = Episode.fromMap(episodeMaps.first);
      } else {
        updatedEpisode = episode;
      }

      // Clear existing content for this episode
      allPages[episodeIndex].clear();
      allPageChapters[episodeIndex].clear();
      allPageImages[episodeIndex].clear();
      pageConversationIds[episodeIndex].clear();
      allPageImages[episodeIndex].add(updatedEpisode.coverImage);

      // Fetch sections
      final sections = await dbHelper.getSections();
      print("Fetched ${sections.length} sections for episode $episodeId");

      // Check for story conversations
      final storyConversations = updatedEpisode.conversations.where((c) => c['storyGenerated'] == true).toList();
      print("Found ${storyConversations.length} story conversations for episode $episodeId");

      if (storyConversations.isNotEmpty) {
        usingConversations.value = true;
        allPages[episodeIndex] = storyConversations.map((c) => c['botResponse'] as String).toList();
        pageConversationIds[episodeIndex] = storyConversations.map((c) => c['_id'] as String).toList();
        if (sections.length == storyConversations.length) {
          allPageChapters[episodeIndex] = sections.map((s) => s.localizedName).toList();
        } else {
          allPageChapters[episodeIndex] = List.generate(allPages[episodeIndex].length, (i) => "Chapter ${i + 1}");
        }
        allPageImages[episodeIndex] = List.filled(allPages[episodeIndex].length, null);
        print("Loaded ${allPages[episodeIndex].length} pages from conversations for episode $episodeId");
      } else {
        usingConversations.value = false;
        if (updatedEpisode.story != null && updatedEpisode.story!.isNotEmpty) {
          _splitStoryContent(episodeIndex, updatedEpisode.story!, sections);
        } else {
          print("No story field, fetching from API for episode $episodeId");
          final response = await apiService.generateStory(bookId!, episodeIndex.toString());
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final story = data['story'];
            _splitStoryContent(episodeIndex, story, sections);

            final newEpisode = updatedEpisode.copyWith(story: story);
            if (episodeMaps.isEmpty) {
              await dbHelper.insertEpisode(newEpisode);
            } else {
              await dbHelper.updateEpisode(newEpisode);
            }
            print("Fetched and saved story from API for episode $episodeId");
          } else {
            throw Exception("Failed to generate story: ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      print("Error loading episode $episodeId: $e");
      allPages[episodeIndex].add("Error loading story");
      allPageChapters[episodeIndex].add("Error");
      pageConversationIds[episodeIndex].add('');
      allPageImages[episodeIndex].add(null);
    }
  }

  void _splitStoryContent(int episodeIndex, String story, List<Section> sections) {
    if (story.isEmpty) {
      allPages[episodeIndex].add("No story content available");
      allPageChapters[episodeIndex].add("Part 1");
      pageConversationIds[episodeIndex].add('');
      allPageImages[episodeIndex].add(null);
      return;
    }

    if (sections.isNotEmpty) {
      final partLength = (story.length / sections.length).ceil();
      allPages[episodeIndex] = List.generate(sections.length, (index) {
        final start = index * partLength;
        final end = (index + 1) * partLength < story.length ? (index + 1) * partLength : story.length;
        return story.substring(start, end);
      });
      allPageChapters[episodeIndex] = sections.map((s) => s.localizedName).toList();
      pageConversationIds[episodeIndex] = List.filled(sections.length, '');
      allPageImages[episodeIndex] = List.filled(sections.length, null);
    } else {
      const int wordsPerPage = 50;
      List<String> words = story.split(' ');
      for (var i = 0; i < words.length; i += wordsPerPage) {
        final pageWords = words.sublist(
          i,
          i + wordsPerPage < words.length ? i + wordsPerPage : words.length,
        );
        allPages[episodeIndex].add(pageWords.join(' '));
        allPageChapters[episodeIndex].add("Part ${allPages[episodeIndex].length}");
        pageConversationIds[episodeIndex].add('');
        allPageImages[episodeIndex].add(null);
      }
    }
    print("Split story into ${allPages[episodeIndex].length} pages for episode $episodeIndex");
  }

  Future<void> updateChapterContent(int episodeIndex, int pageIndex, String newContent) async {
    if (episodeIndex < 0 || episodeIndex >= allPages.length || pageIndex < 0 || pageIndex >= allPages[episodeIndex].length) {
      throw Exception("Invalid indices: episodeIndex=$episodeIndex, pageIndex=$pageIndex");
    }
    print("Updating episode $episodeIndex, page $pageIndex with new content: ${newContent.substring(0, newContent.length < 60 ? newContent.length : 60)}...");

    allPages[episodeIndex][pageIndex] = newContent;

    final conversationId = pageConversationIds[episodeIndex][pageIndex];
    if (usingConversations.value && conversationId.isNotEmpty) {
      final apiData = {'botResponse': newContent};
      try {
        final response = await apiService.updateConversation(bookId!, episodes[episodeIndex].id, conversationId, apiData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await updateDatabaseStory(episodeIndex);
          print("Successfully updated content for episode $episodeIndex, page $pageIndex via API");
        } else {
          Get.snackbar('Error', 'Failed to update server: ${response.body}');
        }
      } catch (e) {
        Get.snackbar('Error', 'API call error: $e');
      }
    } else {
      await updateDatabaseStory(episodeIndex);
      print("Updated content locally for episode $episodeIndex, page $pageIndex");
    }

    // Re-flatten pages to update PageView
    _flattenPages();
  }

  Future<void> updateChapterTitle(int episodeIndex, int pageIndex, String newTitle) async {
    if (episodeIndex < 0 || episodeIndex >= allPageChapters.length || pageIndex < 0 || pageIndex >= allPageChapters[episodeIndex].length) {
      throw Exception("Invalid indices: episodeIndex=$episodeIndex, pageIndex=$pageIndex");
    }
    allPageChapters[episodeIndex][pageIndex] = newTitle;
    print("Updated title for episode $episodeIndex, page $pageIndex to: $newTitle");

    // Re-flatten pages to update PageView
    _flattenPages();
  }

  Future<void> updateDatabaseStory(int episodeIndex) async {
    if (bookId == null || episodeIndex >= episodes.length) return;

    final episodeId = episodes[episodeIndex].id;
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
        for (int i = 0; i < allPages[episodeIndex].length; i++) {
          final convoId = pageConversationIds[episodeIndex][i];
          final convoIndex = updatedConversations.indexWhere((c) => c['_id'] == convoId);
          if (convoIndex != -1) {
            updatedConversations[convoIndex]['botResponse'] = allPages[episodeIndex][i];
          }
        }
        final updatedEpisode = episode.copyWith(conversations: updatedConversations);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated conversations in database for episode $episodeId");
      } else {
        final updatedStory = allPages[episodeIndex].join(' ');
        final updatedEpisode = episode.copyWith(story: updatedStory);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated story in database for episode $episodeId");
      }
    }
  }
}