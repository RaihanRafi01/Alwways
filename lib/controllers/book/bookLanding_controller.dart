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
      final dbBooks = await dbHelper.getBooks();
      books.assignAll(dbBooks);
      print("Loaded ${books.length} books from database");

      final apiBooks = await apiService.getAllBooks();
      for (var book in apiBooks) {
        print("Book '${book.title}' coverImage: '${book.coverImage}'");
        for (var episode in book.episodes) {
          print(
              "Episode '${episode.title}' coverImage: '${episode.coverImage}'");
        }
      }

      for (var apiBook in apiBooks) {
        final dbBook = books.firstWhereOrNull((b) => b.id == apiBook.id);
        if (dbBook != null) {
          final mergedEpisodes = apiBook.episodes.map((apiEpisode) {
            final dbEpisode = dbBook.episodes.firstWhereOrNull((e) =>
            e.id == apiEpisode.id);
            if (dbEpisode != null && dbEpisode.story != null) {
              return apiEpisode.copyWith(
                story: dbEpisode.story,
                backgroundCover: dbEpisode.backgroundCover ??
                    apiEpisode.backgroundCover,
              );
            }
            return apiEpisode;
          }).toList();
          final mergedBook = apiBook.copyWith(episodes: mergedEpisodes);
          await dbHelper.insertBook(mergedBook);
        } else {
          await dbHelper.insertBook(apiBook);
        }
      }

      books.assignAll(await dbHelper.getBooks());
      print("Updated books with API data: ${books.map((b) => b.id).toList()}");
    } catch (e) {
      print("Error fetching books: $e");
    } finally {
      isLoading.value = false;
    }
  }
}