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
  var backgroundCovers = <String, String>{}.obs; // Key: bookId or episodeId
  var coverImages = <String, String>{}.obs; // Key: bookId or episodeId
  var books = <Book>[].obs;
  var bookCoverImage = ''.obs; // Tracks picked image for both books and episodes
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
      for (var episode in book.episodes) {
        backgroundCovers[episode.id] = episode.backgroundCover ?? 'assets/images/book/cover_image_1.svg';
        coverImages[episode.id] = episode.coverImage;
      }
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
        for (var episode in localBook.episodes) {
          backgroundCovers[episode.id] = episode.backgroundCover ?? 'assets/images/book/cover_image_1.svg';
          coverImages[episode.id] = episode.coverImage;
        }
      }
      books.value = await dbHelper.getBooks();
    } catch (e) {
      print("Error fetching books from server: $e");
      Get.snackbar('Error', 'Failed to load books from server: $e');
      books.value = localBooks;
    }
  }

  void updateSelectedCover(String id, String cover) {
    backgroundCovers[id] = cover;
  }

  void updateTitle(String id, String newTitle) {
    final bookIndex = books.indexWhere((b) => b.id == id);
    if (bookIndex != -1) {
      // Update book title
      books[bookIndex] = books[bookIndex].copyWith(title: newTitle);
    } else {
      // Update episode title
      for (var book in books) {
        final episodeIndex = book.episodes.indexWhere((e) => e.id == id);
        if (episodeIndex != -1) {
          book.episodes[episodeIndex] = book.episodes[episodeIndex].copyWith(title: newTitle);
          books.refresh(); // Trigger UI update
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
    if (book != null) {
      return book.title;
    }
    for (var b in books) {
      final episode = b.episodes.firstWhereOrNull((e) => e.id == id);
      if (episode != null) {
        return episode.title;
      }
    }
    return '';
  }

  void updateCoverImage(String id, String imagePath) {
    coverImages[id] = imagePath;
    bookCoverImage.value = imagePath;
  }

  Future<void> _updateBookInDb(String bookId) async {
    final book = books.firstWhere((b) => b.id == bookId);
    final updatedBook = Book(
      id: book.id,
      userId: book.userId,
      title: book.title,
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

  Future<void> _updateEpisodeInDb(String episodeId) async {
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

  Future<void> updateBookCoverApi(String id) async {
    try {
      isLoading.value = true;
      final book = books.firstWhereOrNull((b) => b.id == id);
      if (book != null) {
        // Update book
        final bookTitle = book.title;
        XFile? coverImage;

        if (bookCoverImage.value.isNotEmpty && bookCoverImage.value != book.coverImage) {
          coverImage = XFile(bookCoverImage.value);
          print("Sending coverImage for book: ${bookCoverImage.value}");
        } else {
          print("No new coverImage to send for book");
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
        }
      } else {
        // Update episode
        for (var book in books) {
          final episode = book.episodes.firstWhereOrNull((e) => e.id == id);
          if (episode != null) {
            final episodeTitle = episode.title;
            XFile? coverImage;

            if (bookCoverImage.value.isNotEmpty && bookCoverImage.value != episode.coverImage) {
              coverImage = XFile(bookCoverImage.value);
              print("Sending coverImage for episode: ${bookCoverImage.value}");
            } else {
              print("No new coverImage to send for episode");
            }

            // Assuming API supports episode cover updates; adjust if different
            final response = await apiService.updateBookCover(
              id, // Use episode ID here; ensure API accepts it
              episodeTitle,
              coverImage,
            );
            print('::::::::::::statusCode:::::::::::::: ${response.statusCode}');
            print('::::::::::::::body:::::::::::: ${response.body}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              await _updateEpisodeInDb(id);
              Get.snackbar('Success', 'Episode cover updated successfully');
              Get.back();
              bookCoverImage.value = '';
            } else {
              Get.snackbar('Error', 'Failed to update episode cover: ${response.body}');
            }
            break;
          }
        }
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
    String? title,
    String? coverImage,
    String? backgroundCover,
    List<Episode>? episodes,
  }) {
    return Book(
      id: id,
      userId: userId,
      title: title ?? this.title,
      episodes: episodes ?? this.episodes,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      status: status,
      percentage: percentage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension EpisodeExtension on Episode {
  Episode copyWith({
    String? title,
    String? coverImage,
    String? backgroundCover,
  }) {
    return Episode(
      id: id,
      bookId: bookId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      percentage: percentage,
      conversations: conversations,
    );
  }
}