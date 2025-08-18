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
  final RxInt currentPage = 0.obs;

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

  Future<void> loadAllEpisodes(
      String bookId, String bookTitle, String bookCoverImage) async {
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
      pageConversationIds.value =
          List.generate(episodes.length, (_) => <String>[]);

      // Load content for each episode
      for (var episodeIndex = 0;
          episodeIndex < episodes.length;
          episodeIndex++) {
        await _loadEpisodeContent(episodeIndex);
      }

      // Flatten pages for PageView
      _flattenPages();
    } catch (e) {
      print("Error in loadAllEpisodes: $e");
      Get.snackbar('Error', 'Failed to load episodes: $e');
      flatPages.add({'type': 'error', 'message': 'No content yet'});
    } finally {
      isLoading.value = false;
    }
  }

  void _flattenPages() {
    flatPages.clear();
    // Add book cover page
    flatPages.add({'type': 'book_cover'});
    print("Added book cover page");

    // Add episode pages
    for (var episodeIndex = 0; episodeIndex < episodes.length; episodeIndex++) {
      // Episode cover
      flatPages.add({
        'type': 'episode_cover',
        'episodeIndex': episodeIndex,
      });
      print("Added episode cover for episode $episodeIndex");

      // Story pages
      for (var pageIndex = 0;
          pageIndex < allPages[episodeIndex].length;
          pageIndex++) {
        flatPages.add({
          'type': 'story',
          'episodeIndex': episodeIndex,
          'pageIndex': pageIndex,
        });
        print("Added story page $pageIndex for episode $episodeIndex");
      }
    }
    print(
        "Flattened ${flatPages.length} pages for PageView: ${flatPages.map((p) => p['type'])}");
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
      print("Cleared content and added cover image for episode $episodeId");

      // Fetch sections
      final sections = await dbHelper.getSections();
      print("Fetched ${sections.length} sections for episode $episodeId");

      // Check for story conversations
      final storyConversations = updatedEpisode.conversations
          .where((c) => c['storyGenerated'] == true)
          .toList();
      print(
          "Found ${storyConversations.length} story conversations for episode $episodeId");

      if (storyConversations.isNotEmpty) {
        usingConversations.value = true;
        if (storyConversations.length == 1) {
          // Single conversation: Split the botResponse using _splitStoryContent
          final conversation = storyConversations[0];
          final storyContent = conversation['botResponse'] as String;
          final conversationId = conversation['_id'] as String;
          print(
              "Single conversation for episode $episodeId, content: ${storyContent.length > 60 ? storyContent.substring(0, 60) : storyContent}");
          _splitStoryContent(
              episodeIndex, storyContent, sections, conversationId);
          print(
              "Split conversation into ${allPages[episodeIndex].length} pages for episode $episodeId");
        } else {
          // Multiple conversations: Each conversation is a page
          allPages[episodeIndex] = storyConversations
              .map((c) => c['botResponse'] as String)
              .toList();
          pageConversationIds[episodeIndex] =
              storyConversations.map((c) => c['_id'] as String).toList();
          if (sections.length >= storyConversations.length) {
            allPageChapters[episodeIndex] = sections
                .map((s) => s.localizedName)
                .take(storyConversations.length)
                .toList();
          } else {
            allPageChapters[episodeIndex] = List.generate(
                allPages[episodeIndex].length, (i) => "Chapter ${i + 1}");
          }
          allPageImages[episodeIndex].addAll(
              List<String?>.filled(allPages[episodeIndex].length, null));
          print(
              "Loaded ${allPages[episodeIndex].length} pages from conversations for episode $episodeId: ${allPages[episodeIndex].map((p) => p.length > 60 ? p.substring(0, 60) : p)}");
        }
      } else {
        usingConversations.value = false;
        if (updatedEpisode.story != null && updatedEpisode.story!.isNotEmpty) {
          _splitStoryContent(episodeIndex, updatedEpisode.story!, sections, '');
        } else {
          print("No story field, fetching from API for episode $episodeId");
          final response =
              await apiService.generateStory(bookId!, episodeIndex.toString());
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final story = data['story'];
            _splitStoryContent(episodeIndex, story, sections, '');

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
      allPages[episodeIndex].add("No stories yet");
      allPageChapters[episodeIndex].add("Error");
      pageConversationIds[episodeIndex].add('');
      allPageImages[episodeIndex].add(null);
    }
  }

  void _splitStoryContent(
      int episodeIndex, String story, List<Section> sections,
      [String conversationId = '']) {
    print(
        "Starting _splitStoryContent for episode $episodeIndex with story length: ${story.length}");
    print(
        "Story content (first 100 chars): ${story.length > 100 ? story.substring(0, 100) : story}");

    allPages[episodeIndex].clear();
    allPageChapters[episodeIndex].clear();
    pageConversationIds[episodeIndex].clear();
    // Note: allPageImages[episodeIndex] already has the episode cover image, so we don't clear it

    if (story.isEmpty) {
      print(
          "Story is empty, adding single empty page for episode $episodeIndex");
      allPages[episodeIndex].add('');
      allPageChapters[episodeIndex]
          .add(episodes[episodeIndex].localizedTitle); // Use episode title
      pageConversationIds[episodeIndex].add(conversationId);
      allPageImages[episodeIndex].add(null);
      return;
    }

    final words =
        story.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    print("Found ${words.length} words for episode $episodeIndex");

    const wordsPerPage = 60;
    final episodeTitle = episodes[episodeIndex].localizedTitle;
    for (var i = 0; i < words.length; i += wordsPerPage) {
      final pageWords = words.skip(i).take(wordsPerPage).toList();
      final pageContent = pageWords.join(' ').trim();
      if (pageContent.isNotEmpty) {
        allPages[episodeIndex].add(pageContent);
        // Use episode title for all pages, with part number for multi-page stories
        final pageNumber = allPages[episodeIndex].length;
        allPageChapters[episodeIndex].add(episodeTitle);
        pageConversationIds[episodeIndex].add(conversationId);
        allPageImages[episodeIndex].add(null);
        print(
            "Added page $pageNumber for episode $episodeIndex: ${pageContent.length > 60 ? pageContent.substring(0, 60) : pageContent}...");
      }
    }

    // Ensure at least one page for short content
    if (allPages[episodeIndex].isEmpty) {
      allPages[episodeIndex].add(story);
      allPageChapters[episodeIndex].add(episodeTitle);
      pageConversationIds[episodeIndex].add(conversationId);
      allPageImages[episodeIndex].add(null);
      print(
          "Added single page for short content in episode $episodeIndex: ${story.length > 60 ? story.substring(0, 60) : story}");
    }

    // Ensure minimum pages (e.g., 2)
    while (allPages[episodeIndex].length < 2) {
      allPages[episodeIndex].add('');
      allPageChapters[episodeIndex].add(episodeTitle);
      pageConversationIds[episodeIndex].add(conversationId);
      allPageImages[episodeIndex].add(null);
      print(
          "Added empty page to reach minimum page count for episode $episodeIndex: ${allPages[episodeIndex].length}");
    }

    print(
        "Split story into ${allPages[episodeIndex].length} pages for episode $episodeIndex");
    print(
        "allPages content for episode $episodeIndex: ${allPages[episodeIndex].map((p) => p.length > 60 ? p.substring(0, 60) : p)}");
    print(
        "allPageChapters for episode $episodeIndex: ${allPageChapters[episodeIndex]}");
  }

  Future<void> updateChapterContent(
      int episodeIndex, int pageIndex, String newContent) async {
    if (episodeIndex < 0 ||
        episodeIndex >= allPages.length ||
        pageIndex < 0 ||
        pageIndex >= allPages[episodeIndex].length) {
      throw Exception(
          "Invalid indices: episodeIndex=$episodeIndex, pageIndex=$pageIndex");
    }
    print(
        "Updating episode $episodeIndex, page $pageIndex with new content: ${newContent.length > 60 ? newContent.substring(0, 60) : newContent}...");

    allPages[episodeIndex][pageIndex] = newContent;

    final conversationId = pageConversationIds[episodeIndex][pageIndex];
    if (usingConversations.value && conversationId.isNotEmpty) {
      final apiData = {'botResponse': allPages[episodeIndex].join(' ')};
      try {
        final response = await apiService.updateConversation(
            bookId!, episodes[episodeIndex].id, conversationId, apiData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await updateDatabaseStory(episodeIndex);
          print(
              "Successfully updated content for episode $episodeIndex, page $pageIndex via API");
        } else {
          Get.snackbar('Error', 'Failed to update server: ${response.body}');
        }
      } catch (e) {
        Get.snackbar('Error', 'API call error: $e');
      }
    } else {
      await updateDatabaseStory(episodeIndex);
      print(
          "Updated content locally for episode $episodeIndex, page $pageIndex");
    }

    // Re-flatten pages to update PageView
    _flattenPages();
  }

  Future<void> updateChapterTitle(
      int episodeIndex, int pageIndex, String newTitle) async {
    if (episodeIndex < 0 ||
        episodeIndex >= allPageChapters.length ||
        pageIndex < 0 ||
        pageIndex >= allPageChapters[episodeIndex].length) {
      throw Exception(
          "Invalid indices: episodeIndex=$episodeIndex, pageIndex=$pageIndex");
    }
    allPageChapters[episodeIndex][pageIndex] = newTitle;
    print(
        "Updated title for episode $episodeIndex, page $pageIndex to: $newTitle");

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
        final convoIndex = updatedConversations.indexWhere(
            (c) => c['_id'] == pageConversationIds[episodeIndex][0]);
        if (convoIndex != -1) {
          updatedConversations[convoIndex]['botResponse'] =
              allPages[episodeIndex].join(' ');
          updatedConversations[convoIndex]['title'] =
              allPageChapters[episodeIndex][0];
        }
        final updatedEpisode =
            episode.copyWith(conversations: updatedConversations);
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
