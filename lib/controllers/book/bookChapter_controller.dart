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

  Future<void> loadStory(String bookId, String episodeId, String episodeCoverImage) async {
    this.bookId = bookId;
    this.episodeId = episodeId;
    print("Starting loadStory for bookId: $bookId, episodeId: $episodeId");
    isLoading.value = true;

    try {
      // Find the book
      final book = bookController.books.firstWhere(
            (b) => b.id == bookId,
        orElse: () => throw Exception("Book not found: $bookId"),
      );
      print("Book found: ${book.title}, Episodes: ${book.episodes.length}");

      // Find the episode by ID or index
      Episode episode;
      if (RegExp(r'^\d+$').hasMatch(episodeId)) {
        // If episodeId is a number, treat it as an index
        final index = int.parse(episodeId);
        if (index < 0 || index >= book.episodes.length) {
          throw Exception("Invalid episode index: $episodeId");
        }
        episode = book.episodes[index];
        this.episodeId = episode.id; // Update episodeId to actual ID
      } else {
        // Treat episodeId as an ID
        episode = book.episodes.firstWhere(
              (e) => e.id == episodeId,
          orElse: () => throw Exception("Episode not found: $episodeId"),
        );
      }
      print("Episode loaded: ${episode.title}, Episode ID: ${episode.id}");

      // Fetch episode from database or use the one from book
      final db = await dbHelper.database;
      final episodeMaps = await db.query(
        'episodes',
        where: 'bookId = ? AND id = ?',
        whereArgs: [bookId, episode.id],
      );

      Episode dbEpisode;
      if (episodeMaps.isNotEmpty) {
        dbEpisode = Episode.fromMap(episodeMaps.first);
        print("Episode fetched from DB: ${dbEpisode.title}, Story: ${dbEpisode.story?.substring(0, dbEpisode.story != null && dbEpisode.story!.length > 50 ? 50 : dbEpisode.story?.length ?? 0)}...");
      } else {
        dbEpisode = episode;
        print("Episode from book: ${episode.title}, Story: ${episode.story?.substring(0, episode.story != null && episode.story!.length > 50 ? 50 : episode.story?.length ?? 0)}...");
      }

      // Reset all lists to ensure clean state
      allPages.clear();
      allPageChapters.clear();
      allPageImages.clear();
      pageConversationIds.clear();

      // Add the episode cover image as the first page
      allPageImages.add(episodeCoverImage);
      print("Added cover image: $episodeCoverImage");

      // Fetch sections
      final sections = await dbHelper.getSections();
      print("Fetched ${sections.length} sections: ${sections.map((s) => s.localizedName).toList()}");

      // Check for story conversations
      final storyConversations = dbEpisode.conversations.where((c) => c['storyGenerated'] == true).toList();
      print("Found ${storyConversations.length} story conversations: ${storyConversations.map((c) => c['_id']).toList()}");

      if (storyConversations.isNotEmpty) {
        usingConversations.value = true;
        if (storyConversations.length == 1) {
          // Single conversation: Split the botResponse using _splitStoryContent
          story.value = storyConversations[0]['botResponse'] as String;
          print("Single conversation, botResponse length: ${story.value.length}, content: ${story.value.substring(0, story.value.length < 100 ? story.value.length : 100)}...");
          _splitStoryContent(story.value, storyConversations[0]['_id'] as String, sections);
          pageConversationIds.value = List.generate(allPages.length, (_) => storyConversations[0]['_id'] as String);
          if (sections.length >= allPages.length) {
            allPageChapters.value = sections.map((s) => s.localizedName).take(allPages.length).toList();
          } else {
            allPageChapters.value = List.generate(allPages.length, (i) => "Chapter ${i + 1}");
          }
          allPageImages.addAll(List<String?>.filled(allPages.length, null));
          print("Split single conversation into ${allPages.length} pages");
        } else {
          // Multiple conversations: Each conversation is a page
          allPages.value = storyConversations.map((c) => c['botResponse'] as String).toList();
          pageConversationIds.value = storyConversations.map((c) => c['_id'] as String).toList();
          if (sections.length >= storyConversations.length) {
            allPageChapters.value = sections.map((s) => s.localizedName).take(storyConversations.length).toList();
          } else {
            allPageChapters.value = List.generate(allPages.length, (i) => "Chapter ${i + 1}");
          }
          allPageImages.addAll(List<String?>.filled(allPages.length, null));
          print("Loaded ${allPages.length} pages from conversations: ${allPages.map((p) => p.substring(0, p.length < 50 ? p.length : 50)).toList()}");
        }
      } else {
        usingConversations.value = false;
        if (dbEpisode.story != null && dbEpisode.story!.isNotEmpty) {
          story.value = dbEpisode.story!;
          print("Using episode story, length: ${story.value.length}");
          _splitStoryContent(story.value, '', sections);
        } else {
          print("No story field, fetching from API");
          final episodeIndex = book.episodes.indexWhere((e) => e.id == episode.id);
          if (episodeIndex == -1) {
            throw Exception("Episode not found in book episodes");
          }
          final response = await apiService.generateStory(bookId, episodeIndex.toString());
          print("No story field, fetching from API-------statusCode---------> ${response.statusCode}");
          print("No story field, fetching from API--------body--------> ${response.body}");
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            story.value = data['story'];
            print("Story fetched from API, length: ${story.value.length}, content: ${story.value.substring(0, story.value.length < 50 ? story.value.length : 50)}...");
            _splitStoryContent(story.value, '', sections);

            final updatedEpisode = dbEpisode.copyWith(story: story.value);
            if (episodeMaps.isEmpty) {
              await dbHelper.insertEpisode(updatedEpisode);
            } else {
              await dbHelper.updateEpisode(updatedEpisode);
            }
            print("Fetched and saved story from API for episode ${episode.id}");
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
      print("LoadStory completed, page count: ${allPages.length}");
    } catch (e) {
      print("Error in loadStory: $e");
      Get.snackbar('Error', 'Failed to load story: $e');
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

  Future<void> updateChapterTitle(int index, String newTitle) async {
    if (index < 0 || index >= allPageChapters.length) {
      throw Exception("Invalid chapter index: $index");
    }
    print("Updating title for page $index to: $newTitle");
    allPageChapters[index] = newTitle;
    await updateDatabaseStory();
  }

  void _splitStoryContent(String story, String conversationId, List<Section> sections) {
    print("Starting _splitStoryContent with story length: ${story.length}");
    print("Story content (first 100 chars): ${story.length > 100 ? story.substring(0, 100) : story}");

    allPages.clear();
    allPageChapters.clear();
    pageConversationIds.clear();

    if (story.isEmpty) {
      print("Story is empty, adding single empty page");
      allPages.add('');
      allPageChapters.add(sections.isNotEmpty ? sections[0].localizedName : 'Chapter 1');
      pageConversationIds.add(conversationId);
      return;
    }

    final words = story.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    print("Found ${words.length} words");

    const wordsPerPage = 70;
    for (var i = 0; i < words.length; i += wordsPerPage) {
      final pageWords = words.skip(i).take(wordsPerPage).toList();
      final pageContent = pageWords.join(' ').trim();
      if (pageContent.isNotEmpty) {
        allPages.add(pageContent);
        allPageChapters.add(sections.length > allPages.length - 1 ? sections[allPages.length - 1].localizedName : 'Chapter ${allPages.length}');
        pageConversationIds.add(conversationId);
        print("Word page ${allPages.length}: ${pageContent.length > 60 ? pageContent.substring(0, 60) : pageContent}...");
      }
    }

    // Ensure at least one page for short content
    if (allPages.isEmpty) {
      allPages.add(story);
      allPageChapters.add(sections.isNotEmpty ? sections[0].localizedName : 'Chapter 1');
      pageConversationIds.add(conversationId);
      print("Added single page for short content: $story");
    }

    // Ensure minimum pages to match expected pageCount (e.g., 2)
    while (allPages.length < 2) {
      allPages.add('');
      allPageChapters.add(sections.length > allPages.length - 1 ? sections[allPages.length - 1].localizedName : 'Chapter ${allPages.length}');
      pageConversationIds.add(conversationId);
      print("Added empty page to reach minimum page count: ${allPages.length}");
    }

    print("Split story into ${allPages.length} pages based on words");
    print("Final page count: ${allPages.length}");
    print("allPages content: $allPages");
  }

  Future<void> updateChapterContent(int index, String newContent) async {
    if (index < 0 || index >= allPages.length) {
      throw Exception("Invalid page index: $index");
    }
    if (newContent.trim().isEmpty) {
      throw Exception("Content cannot be empty");
    }

    // Log content safely
    final logContent = newContent.length > 60 ? newContent.substring(0, newContent.length.clamp(0, 60)) : newContent;
    print("Updating page $index with new content: $logContent...");

    allPages[index] = newContent;

    final conversationId = pageConversationIds[index];
    if (usingConversations.value && conversationId.isNotEmpty) {
      final apiData = {'botResponse': allPages.join(' ')};
      try {
        final response = await apiService.updateConversation(bookId!, episodeId!, conversationId, apiData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          await updateDatabaseStory();
          print("Successfully updated content for page $index via API");
          Get.snackbar('Success', 'Changes saved successfully');
        } else {
          Get.snackbar('Error', 'Failed to update server: ${response.body}');
          await updateDatabaseStory();
        }
      } catch (e) {
        print("API call error: $e");
        Get.snackbar('Error', 'Failed to save changes to server: $e');
        await updateDatabaseStory();
      }
    } else {
      await updateDatabaseStory();
      print("Updated content locally for page $index");
      Get.snackbar('Success', 'Changes saved successfully');
    }
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
        final reconstructedStory = allPages.join(' ');
        final convoIndex = updatedConversations.indexWhere((c) => c['_id'] == pageConversationIds[0]);
        if (convoIndex != -1) {
          updatedConversations[convoIndex]['botResponse'] = reconstructedStory;
          updatedConversations[convoIndex]['title'] = allPageChapters[0];
        }
        final updatedEpisode = episode.copyWith(conversations: updatedConversations);
        await dbHelper.updateEpisode(updatedEpisode);
        print("Updated conversation with full story in database for episode $episodeId");
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