import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/views/book/book_landing.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import '../../services/api_service/api_service.dart';

class BookController extends GetxController {
  TextEditingController bookNameController = TextEditingController(); // Controller for book name
  var title = ''.obs;
  var selectedCover = 'assets/images/book/cover_image_1.svg'.obs; // Default SVG
  //var selectedCoverImage = ''.obs; // For locally picked image
  var coverImages = <String, String>{}.obs;
  var bookCoverImage = ''.obs;
  final ApiService apiService = ApiService();

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

  String getCoverImage(String bookId, String defaultImage) {
    return coverImages[bookId] ?? defaultImage; // Return book-specific image or default
  }

  void updateCoverImage(String bookId, String imagePath) {
    coverImages[bookId] = imagePath; // Update cover image for specific book
    bookCoverImage.value = imagePath; // Update selected cover for editing
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

  Future<void> updateBookCoverApi(String bookId) async {
    try {
      XFile? coverImage = coverImages[bookId]?.isNotEmpty == true
          ? XFile(coverImages[bookId]!)
          : null;
      // Assuming apiService is defined elsewhere
      final response = await apiService.updateBookCover(bookId, title.value, coverImage);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Book cover updated successfully');
        Get.back();
      } else {
        Get.snackbar('Error', 'Failed to update book cover: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}