import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/views/book/book_landing.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import '../../services/api_service/api_service.dart';
import '../../services/database/databaseHelper.dart';
import '../../services/model/bookModel.dart';

class BookController extends GetxController {
  TextEditingController bookNameController = TextEditingController();
  var backgroundCovers = <String, String>{}.obs;
  var coverImages = <String, String>{}.obs;
  var books = <Book>[].obs;
  var bookCoverImage = ''.obs; // Tracks newly picked image
  var isLoading = false.obs;
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();

  List<String> bookCovers = [
    'assets/images/book/cover_image_1.svg',
    'assets/images/book/cover_image_2.svg',
    'assets/images/book/cover_image_3.svg',
    'assets/images/book/cover_image_1.svg',
    'assets/images/book/cover_image_2.svg',
    'assets/images/book/cover_image_3.svg',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeBooks();
  }

  Future<void> _initializeBooks() async {
    final localBooks = await dbHelper.getBooks();
    for (var book in localBooks) {
      backgroundCovers[book.id] = book.backgroundCover;
      coverImages[book.id] = book.coverImage;
    }

    try {
      final serverBooks = await apiService.getAllBooks();
      for (var serverBook in serverBooks) {
        final existingBook = localBooks.firstWhereOrNull((b) => b.id == serverBook.id);
        final localBook = Book(
          id: serverBook.id,
          userId: serverBook.userId,
          title: serverBook.title,
          episodes: serverBook.episodes,
          coverImage: serverBook.coverImage,
          backgroundCover: existingBook?.backgroundCover ?? 'assets/images/book/cover_image_1.svg',
          status: serverBook.status,
          percentage: serverBook.percentage,
          createdAt: serverBook.createdAt,
          updatedAt: serverBook.updatedAt,
        );
        await dbHelper.insertBook(localBook);
        backgroundCovers[localBook.id] = localBook.backgroundCover;
        coverImages[localBook.id] = localBook.coverImage;
      }
      books.value = await dbHelper.getBooks();
    } catch (e) {
      print("Error fetching books from server: $e");
      Get.snackbar('Error', 'Failed to load books from server: $e');
      books.value = localBooks;
    }
  }

  void updateSelectedCover(String bookId, String cover) {
    backgroundCovers[bookId] = cover;
  }

  void updateTitle(String bookId, String newTitle) {
    final bookIndex = books.indexWhere((b) => b.id == bookId);
    if (bookIndex != -1) {
      books[bookIndex] = books[bookIndex].copyWith(title: newTitle);
    }
  }

  String getBackgroundCover(String bookId) {
    return backgroundCovers[bookId] ?? 'assets/images/book/cover_image_1.svg';
  }

  String getCoverImage(String bookId, String defaultImage) {
    return coverImages[bookId] ?? defaultImage;
  }

  String getTitle(String bookId) {
    final book = books.firstWhereOrNull((b) => b.id == bookId);
    return book?.title ?? '';
  }

  void updateCoverImage(String bookId, String imagePath) {
    coverImages[bookId] = imagePath;
    bookCoverImage.value = imagePath;
  }

  Future<void> _updateBookInDb(String bookId) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final updatedBook = Book(
      id: book.id,
      userId: book.userId,
      title: book.title, // Use the updated title from books list
      episodes: book.episodes,
      coverImage: coverImages[bookId] ?? book.coverImage,
      backgroundCover: backgroundCovers[bookId] ?? book.backgroundCover,
      status: book.status,
      percentage: book.percentage,
      createdAt: book.createdAt,
      updatedAt: DateTime.now(),
    );
    await dbHelper.updateBook(updatedBook);
    books[books.indexWhere((b) => b.id == bookId)] = updatedBook;
    print("Database updated for bookId: $bookId with title: ${updatedBook.title}, coverImage: ${updatedBook.coverImage}, backgroundCover: ${updatedBook.backgroundCover}");
  }

  Future<void> createBook() async {
    if (bookNameController.text.isEmpty) {
      Get.snackbar('Error', 'Book name cannot be empty');
      return;
    }

    try {
      final response = await apiService.createBook(bookNameController.text);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final newBookJson = jsonDecode(response.body);
        final newBook = Book.fromJson(newBookJson);
        final localBook = Book(
          id: newBook.id,
          userId: newBook.userId,
          title: newBook.title,
          episodes: newBook.episodes,
          coverImage: newBook.coverImage,
          backgroundCover: 'assets/images/book/cover_image_1.svg',
          status: newBook.status,
          percentage: newBook.percentage,
          createdAt: newBook.createdAt,
          updatedAt: newBook.updatedAt,
        );
        await dbHelper.insertBook(localBook);
        books.add(localBook);
        backgroundCovers[localBook.id] = localBook.backgroundCover;
        coverImages[localBook.id] = localBook.coverImage;
        Get.offAll(const DashboardView(index: 1));
      } else {
        Get.snackbar('Error', 'Failed to create book: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> updateBookCoverApi(String bookId) async {
    try {
      isLoading.value = true;
      final originalBook = books.firstWhere((b) => b.id == bookId);
      final bookTitle = originalBook.title; // Use the updated title from books list
      XFile? coverImage;

      if (bookCoverImage.value.isNotEmpty && bookCoverImage.value != originalBook.coverImage) {
        coverImage = XFile(bookCoverImage.value);
        print("Sending coverImage: ${bookCoverImage.value}");
      } else {
        print("No new coverImage to send");
      }

      print('hit');
      final response = await apiService.updateBookCover(
        bookId,
        bookTitle,
        coverImage,
      );
      print('::::::::::::statusCode:::::::::::::: ${response.statusCode}');
      print('::::::::::::::body:::::::::::: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _updateBookInDb(bookId); // Update DB with specific book's title
        Get.snackbar('Success', 'Book cover updated successfully');
        Get.back();
        bookCoverImage.value = '';
      } else {
        Get.snackbar('Error', 'Failed to update book cover: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

// Add a copyWith method to Book model for easier updates
extension BookExtension on Book {
  Book copyWith({
    String? title,
    String? coverImage,
    String? backgroundCover,
  }) {
    return Book(
      id: id,
      userId: userId,
      title: title ?? this.title,
      episodes: episodes,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      status: status,
      percentage: percentage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}