import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookChapterController extends GetxController {
  final PageController pageController = PageController(); // PageView controller
  final RxInt currentPage = 0.obs; // Observable for the current page index

  final RxList<String> bookChapters = [
    "Landing",
    "Introduction to the Book",
    "Chapter 1 Overview",
    "Chapter 2 Deep Dive",
    "Chapter 3 Analysis",
    "Conclusion"
  ].obs; // List of chapter titles (observable for updates)

  final RxList<String> bookContents = [
    "landing",
    "Writing this book is important to me because I want my family to understand my past life. By sharing my experiences, I hope to create a meaningful connection with them.",
    "Page 2 Content: Chapter 1 Overview",
    "Page 3 Content: Chapter 2 Deep Dive",
    "Page 4 Content: Chapter 3 Analysis",
    "Page 5 Content: Conclusion"
  ].obs; // List of chapter contents (observable for updates)

  @override
  void onInit() {
    super.onInit();
    // Listen to pageController changes
    pageController.addListener(() {
      final pageIndex = pageController.page?.round() ?? 0;
      if (currentPage.value != pageIndex) {
        currentPage.value = pageIndex;
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose(); // Dispose of the PageController
    super.onClose();
  }

  // Method to update chapter content
  void updateChapterContent(int index, String newContent) {
    if (index >= 0 && index < bookContents.length) {
      bookContents[index] = newContent;
    } else {
      throw Exception("Invalid chapter index");
    }
  }

  // Method to update chapter title
  void updateChapterTitle(int index, String newTitle) {
    if (index >= 0 && index < bookChapters.length) {
      bookChapters[index] = newTitle;
    } else {
      throw Exception("Invalid chapter index");
    }
  }

  // Add a new chapter
  void addChapter(String title, String content) {
    bookChapters.add(title);
    bookContents.add(content);
  }

  // Remove a chapter
  void removeChapter(int index) {
    if (index >= 0 && index < bookChapters.length) {
      bookChapters.removeAt(index);
      bookContents.removeAt(index);
    } else {
      throw Exception("Invalid chapter index");
    }
  }
}
