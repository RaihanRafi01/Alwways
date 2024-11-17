import 'package:get/get.dart';

class ChapterController extends GetxController {
  var bookChapter = [
    "Landing",
    "Introduction to the Book",
    "Chapter 1 Overview",
    "Chapter 2 Deep Dive",
    "Chapter 3 Analysis",
    "Conclusion"
  ].obs;

  var bookContent = [
    "landing",
    "Writing this book is important to me because I want my family to understand my past life. By sharing my experiences, I hope to create a meaningful connection with them.",
    "Page 2 Content: Chapter 1 Overview",
    "Page 3 Content: Chapter 2 Deep Dive",
    "Page 4 Content: Chapter 3 Analysis",
    "Page 5 Content: Conclusion"
  ].obs;

  void updateChapter(int index, String title, String content) {
    bookChapter[index] = title;
    bookContent[index] = content;
  }
}
