import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/book/book_landing.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import '../../services/api_service/api_service.dart';

class BookController extends GetxController {
  TextEditingController bookNameController = TextEditingController(); // Controller for book name
  RxString selectedCover = ''.obs;
  RxString selectedCoverImage = ''.obs;
  var title = 'My Life'.obs;

  List<String> bookCovers = [
    'assets/images/book/cover_image_1.svg',
    'assets/images/book/cover_image_2.svg',
    'assets/images/book/cover_image_3.svg',
    'assets/images/book/cover_image_1.svg',
    'assets/images/book/cover_image_2.svg',
    'assets/images/book/cover_image_3.svg',
  ];

  void updateSelectedCover(String cover) {
    selectedCover.value = cover;
  }

  void updateTitle(String newTitle) {
    title.value = newTitle;
  }

  void updateSelectedCoverImage(String coverPath) {
    selectedCoverImage.value = coverPath;
  }

  Future<void> createBook() async {
    if (bookNameController.text.isEmpty) {
      Get.snackbar('Error', 'Book name cannot be empty');
      return;
    }

    try {
      final response = await ApiService().createBook(bookNameController.text);
      if (response.statusCode == 201 || response.statusCode == 200) { // Adjust based on API
        Get.offAll(const DashboardView(index: 1)); // Navigate on success
      } else {
        Get.snackbar('Error', 'Failed to create book: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}