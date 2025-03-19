import 'dart:convert';

import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';

import '../../services/api_service/api_service.dart';
import '../../services/database/databaseHelper.dart';
import '../../services/model/bookModel.dart';

class BookLandingController extends GetxController {
  final ApiService apiService = ApiService();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final RxList<Book> books = <Book>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    isLoading.value = true;
    try {
      // Step 1: Load existing books from database
      final dbBooks = await dbHelper.getBooks();
      books.assignAll(dbBooks);
      print("Loaded ${books.length} books from database");

      // Step 2: Fetch fresh books from API
      final apiBooks = await apiService.getAllBooks();

      // Step 3: Merge API books with database books, preserving stories
      for (var apiBook in apiBooks) {
        final dbBook = books.firstWhereOrNull((b) => b.id == apiBook.id);
        if (dbBook != null) {
          // Merge episodes, preserving stories from database
          final mergedEpisodes = apiBook.episodes.map((apiEpisode) {
            final dbEpisode = dbBook.episodes.firstWhereOrNull((e) => e.id == apiEpisode.id);
            if (dbEpisode != null && dbEpisode.story != null) {
              return dbEpisode; // Keep the full dbEpisode with story
            }
            return apiEpisode; // Use API episode if no story exists
          }).toList();
          final mergedBook = apiBook.copyWith(episodes: mergedEpisodes);
          await dbHelper.insertBook(mergedBook);
        } else {
          // New book, insert directly
          await dbHelper.insertBook(apiBook);
        }
      }

      // Step 4: Reload merged books from database
      books.assignAll(await dbHelper.getBooks());
      print("Updated books with API data, preserved stories: ${books.map((b) => b.id).toList()}");
    } catch (e) {
      print("Error fetching books: $e");
      Get.snackbar('Error', 'Failed to load books: $e');
    } finally {
      isLoading.value = false;
    }
  }
}