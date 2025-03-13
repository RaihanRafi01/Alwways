import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import '../../services/api_service/api_service.dart';
import '../../services/database/databaseHelper.dart';
import '../../services/model/bookModel.dart';

class BookController extends GetxController {
  TextEditingController bookNameController = TextEditingController();
  var backgroundCovers = <String, String>{}.obs;
  var coverImages = <String, String>{}.obs;
  var books = <Book>[].obs;
  var bookCoverImage = ''.obs; // For user-uploaded cover image (e.g., via picker)
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
    initializeBooks();
  }

  Future<void> initializeBooks() async {
    final localBooks = await dbHelper.getBooks();
    print("Initial local books with episodes: ${localBooks.map((b) => {'id': b.id, 'episodes': b.episodes.map((e) => {'id': e.id, 'title': e.title}).toList()})}");
    for (var book in localBooks) {
      backgroundCovers[book.id] = book.backgroundCover;
      coverImages[book.id] = book.coverImage;
      for (var episode in book.episodes) {
        backgroundCovers[episode.id] = episode.backgroundCover ?? 'assets/images/book/cover_image_1.svg';
        coverImages[episode.id] = episode.coverImage;
      }
    }
    books.value = localBooks;

    try {
      final serverBooks = await apiService.getAllBooks();
      print("Server books with episodes: ${serverBooks.map((b) => {'id': b.id, 'episodes': b.episodes.map((e) => {'id': e.id, 'title': e.title}).toList()})}");
      for (var serverBook in serverBooks) {
        final existingBook = localBooks.firstWhereOrNull((b) => b.id == serverBook.id);
        final mergedBook = Book(
          id: serverBook.id,
          userId: serverBook.userId,
          title: serverBook.title,
          episodes: _mergeEpisodes(existingBook?.episodes ?? [], serverBook.episodes),
          coverImage: serverBook.coverImage,
          backgroundCover: existingBook?.backgroundCover ?? 'assets/images/book/cover_image_1.svg',
          status: serverBook.status,
          percentage: serverBook.percentage,
          createdAt: serverBook.createdAt,
          updatedAt: serverBook.updatedAt,
        );
        await dbHelper.insertBook(mergedBook);
        backgroundCovers[mergedBook.id] = mergedBook.backgroundCover;
        coverImages[mergedBook.id] = mergedBook.coverImage;
        for (var episode in mergedBook.episodes) {
          backgroundCovers[episode.id] = episode.backgroundCover ?? 'assets/images/book/cover_image_1.svg';
          coverImages[episode.id] = episode.coverImage;
        }
      }
      books.value = await dbHelper.getBooks();
      print("Updated books with episodes: ${books.map((b) => {'id': b.id, 'episodes': b.episodes.map((e) => {'id': e.id, 'title': e.title}).toList()})}");
    } catch (e) {
      print("Error fetching books from server: $e");
      Get.snackbar('Error', 'Failed to load books from server: $e');
      if (books.isEmpty) books.value = localBooks;
    }
  }

  List<Episode> _mergeEpisodes(List<Episode> localEpisodes, List<Episode> serverEpisodes) {
    final mergedEpisodes = <Episode>[];
    for (var serverEpisode in serverEpisodes) {
      final localEpisode = localEpisodes.firstWhereOrNull((e) => e.id == serverEpisode.id);
      mergedEpisodes.add(
        Episode(
          id: serverEpisode.id,
          bookId: serverEpisode.bookId,
          title: serverEpisode.title,
          coverImage: serverEpisode.coverImage,
          backgroundCover: localEpisode?.backgroundCover ?? 'assets/images/book/cover_image_1.svg',
          percentage: serverEpisode.percentage,
          conversations: serverEpisode.conversations,
        ),
      );
    }
    return mergedEpisodes;
  }

  void updateSelectedCover(String id, String cover) {
    backgroundCovers[id] = cover; // Only updates backgroundCover
  }

  void updateCoverImage(String id, String imagePath) {
    coverImages[id] = imagePath; // Only updates coverImage
    bookCoverImage.value = imagePath; // Tracks user-uploaded image for API
  }

  void updateTitle(String id, String newTitle) {
    final bookIndex = books.indexWhere((b) => b.id == id);
    if (bookIndex != -1) {
      books[bookIndex] = books[bookIndex].copyWith(title: newTitle);
    } else {
      for (var book in books) {
        final episodeIndex = book.episodes.indexWhere((e) => e.id == id);
        if (episodeIndex != -1) {
          book.episodes[episodeIndex] = book.episodes[episodeIndex].copyWith(title: newTitle);
          books.refresh();
          break;
        }
      }
    }
  }

  String getBackgroundCover(String id) {
    return backgroundCovers[id] ?? 'assets/images/book/cover_image_1.svg';
  }

  String getCoverImage(String id, String defaultImage) {
    return coverImages[id] ?? defaultImage;
  }

  String getTitle(String id) {
    final book = books.firstWhereOrNull((b) => b.id == id);
    if (book != null) return book.title;
    for (var b in books) {
      final episode = b.episodes.firstWhereOrNull((e) => e.id == id);
      if (episode != null) return episode.title;
    }
    return '';
  }

  Future<void> _updateBookInDb(String bookId) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final updatedBook = book.copyWith(
      coverImage: coverImages[bookId] ?? book.coverImage,
      backgroundCover: backgroundCovers[bookId] ?? book.backgroundCover,
      updatedAt: DateTime.now(),
    );
    await dbHelper.updateBook(updatedBook);
    books[books.indexWhere((b) => b.id == bookId)] = updatedBook;
    print("Database updated for bookId: $bookId with title: ${updatedBook.title}, coverImage: ${updatedBook.coverImage}, backgroundCover: ${updatedBook.backgroundCover}");
  }

  Future<void> updateEpisodeInDb(String episodeId) async {
    for (var book in books) {
      final episodeIndex = book.episodes.indexWhere((e) => e.id == episodeId);
      if (episodeIndex != -1) {
        final updatedEpisode = book.episodes[episodeIndex].copyWith(
          coverImage: coverImages[episodeId] ?? book.episodes[episodeIndex].coverImage,
          backgroundCover: backgroundCovers[episodeId] ?? book.episodes[episodeIndex].backgroundCover,
        );
        book.episodes[episodeIndex] = updatedEpisode;
        await dbHelper.updateEpisode(updatedEpisode);
        books.refresh();
        print("Database updated for episodeId: $episodeId with title: ${updatedEpisode.title}, coverImage: ${updatedEpisode.coverImage}, backgroundCover: ${updatedEpisode.backgroundCover}");
        break;
      }
    }
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
        final localBook = newBook.copyWith(backgroundCover: 'assets/images/book/cover_image_1.svg');
        await dbHelper.insertBook(localBook);
        books.add(localBook);
        backgroundCovers[localBook.id] = localBook.backgroundCover;
        coverImages[localBook.id] = localBook.coverImage;
        for (var episode in localBook.episodes) {
          backgroundCovers[episode.id] = episode.backgroundCover ?? 'assets/images/book/cover_image_1.svg';
          coverImages[episode.id] = episode.coverImage;
        }
        Get.offAll(const DashboardView(index: 1));
      } else {
        Get.snackbar('Error', 'Failed to create book: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> updateEpisodeCoverApi(String episodeId, int episodeNumber) async {
    try {
      isLoading.value = true;
      for (var book in books) {
        final episode = book.episodes.firstWhereOrNull((e) => e.id == episodeId);
        if (episode != null) {
          XFile? coverImage;

          // Only send coverImage if it’s explicitly updated (not backgroundCover)
          if (bookCoverImage.value.isNotEmpty && bookCoverImage.value != episode.coverImage) {
            coverImage = XFile(bookCoverImage.value);
            print("Sending coverImage for episode: ${bookCoverImage.value}, bookId: ${book.id}, episodeNumber: $episodeNumber");

            final response = await apiService.updateEpisodeCover(
              book.id,
              coverImage,
              episodeNumber,
            );
            print('::::::::::::statusCode:::::::::::::: ${response.statusCode}');
            print('::::::::::::::body:::::::::::: ${response.body}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              await updateEpisodeInDb(episodeId);
              Get.snackbar('Success', 'Episode cover updated successfully');
              Get.back();
              bookCoverImage.value = '';
            } else {
              Get.snackbar('Error', 'Failed to update episode cover: ${response.body}');
            }
          } else {
            print("No new coverImage for episode, saving locally (backgroundCover may have changed)");
            await updateEpisodeInDb(episodeId);
            Get.snackbar('Success', 'Episode updated successfully');
            Get.back();
          }
          break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBookCoverApi(String id) async {
    try {
      isLoading.value = true;
      final book = books.firstWhereOrNull((b) => b.id == id);
      if (book != null) {
        final bookTitle = book.title;
        XFile? coverImage;

        // Only send coverImage if it’s explicitly updated
        if (bookCoverImage.value.isNotEmpty && bookCoverImage.value != book.coverImage) {
          coverImage = XFile(bookCoverImage.value);
          print("Sending coverImage for book: ${bookCoverImage.value}");
        } else {
          print("No new coverImage for book, saving locally (backgroundCover may have changed)");
        }

        final response = await apiService.updateBookCover(
          id,
          bookTitle,
          coverImage,
        );
        print('::::::::::::statusCode:::::::::::::: ${response.statusCode}');
        print('::::::::::::::body:::::::::::: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _updateBookInDb(id);
          Get.snackbar('Success', 'Book cover updated successfully');
          Get.back();
          bookCoverImage.value = '';
        } else {
          Get.snackbar('Error', 'Failed to update book cover: ${response.body}');
          await _updateBookInDb(id); // Save backgroundCover changes locally even if API fails
          Get.back();
        }
      } else {
        await updateEpisodeCoverApi(id, 0);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

extension BookExtension on Book {
  Book copyWith({
    String? id,
    String? userId,
    String? title,
    List<Episode>? episodes,
    String? coverImage,
    String? backgroundCover,
    String? status,
    double? percentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      episodes: episodes ?? this.episodes,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      status: status ?? this.status,
      percentage: percentage ?? this.percentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension EpisodeExtension on Episode {
  Episode copyWith({
    String? id,
    String? bookId,
    String? title,
    String? coverImage,
    String? backgroundCover,
    double? percentage,
    List<dynamic>? conversations,
  }) {
    return Episode(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      percentage: percentage ?? this.percentage,
      conversations: conversations ?? this.conversations,
    );
  }
}