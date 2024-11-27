import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookChapterController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final RxList<String> bookChapters = [
    "Landing",
    "Introduction to the Book",
    "Chapter 1 Overview",
    "Chapter 2 Deep Dive",
    "Chapter 3 Analysis",
    "Conclusion"
  ].obs;

  final RxList<String> bookContents = [
    "Landing",
    "ChapterCover",
    "Page 2 Content: Chapter 1 Overview",
    "Page 3 Content: Chapter 2 Deep Dive",
    "Page 4 Content: Chapter 3 Analysis",
    "Page 5 Content: Conclusion"
  ].obs;

  // Initialize with null images for each chapter
  late RxList<String?> bookImages = List<String?>.filled(bookContents.length, null).obs;

  final RxList<String> allPages = <String>[].obs; // Flattened pages
  final RxList<String> allPageChapters = <String>[].obs; // Flattened chapter mapping
  final RxList<String?> allPageImages = <String?>[].obs; // Flattened image mapping

  @override
  void onInit() {
    super.onInit();
    _splitContentIntoPages(); // Initialize flattened content
    pageController.addListener(_onPageChanged);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.onClose();
  }

  // Listener for page controller
  void _onPageChanged() {
    final pageIndex = pageController.page?.round() ?? 0;
    if (currentPage.value != pageIndex) {
      currentPage.value = pageIndex;
    }
  }

  // Split content into pages, ensuring valid word count per page
  void _splitContentIntoPages({int maxWordsPerPage = 10}) {
    allPages.clear();
    allPageChapters.clear();
    allPageImages.clear();

    for (var i = 0; i < bookContents.length; i++) {
      final content = bookContents[i];
      final chapterTitle = bookChapters[i];
      final chapterImage = bookImages[i];

      // Break content into pages based on word count
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
  }

  // Update image for a chapter and refresh mappings
  void updateChapterImage(int index, String? imagePath) {
    if (index.isNegative || index >= bookImages.length) {
      throw Exception("Invalid chapter index");
    }
    bookImages[index] = imagePath;
    _splitContentIntoPages(); // Update flattened lists
  }

  // Update content for a chapter and refresh mappings
  void updateChapterContent(int index, String newContent) {
    if (index.isNegative || index >= bookContents.length) {
      throw Exception("Invalid chapter index");
    }
    bookContents[index] = newContent;
    _splitContentIntoPages(); // Update flattened lists
  }

  // Update chapter title and refresh mappings
  void updateChapterTitle(int index, String newTitle) {
    if (index.isNegative || index >= bookChapters.length) {
      throw Exception("Invalid chapter index");
    }
    bookChapters[index] = newTitle;
    _splitContentIntoPages(); // Update flattened lists
  }
}
