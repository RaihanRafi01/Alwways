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
  var bookCoverImage = ''.obs; // For user-uploaded cover image
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

  bool _hasInitialized = false;

  @override
  void onInit() {
    super.onInit();
    if (!_hasInitialized) {
      initializeBooks();
      _hasInitialized = true;
    }
  }

  Future<void> initializeBooks() async {
    isLoading.value = true;
    try {
      final localBooks = await dbHelper.getBooks();
      books.value = localBooks;
      _populateCovers(localBooks);

      final serverBooks = await apiService.getAllBooks();
      print("Server books fetched: ${serverBooks.length}");

      for (var serverBook in serverBooks) {
        final existingBook = localBooks.firstWhereOrNull((b) => b.id == serverBook.id);
        final mergedBook = _mergeBook(existingBook, serverBook);
        await dbHelper.insertBook(mergedBook);
        await _processConversations(mergedBook);
      }

      books.value = await dbHelper.getBooks();
      _populateCovers(books);

      for (var book in books) {
        final calculatedPercentage = calculateBookPercentage(book);
        print("Calculated percentage for book '${book.title}' (ID: ${book.id}): $calculatedPercentage%");
        final updatedBook = book.copyWith(percentage: calculatedPercentage);
        await dbHelper.updateBook(updatedBook);
        await apiService.updateBookPercentage(updatedBook.id, updatedBook.percentage);
      }

      books.value = await dbHelper.getBooks();
      print("Books list refreshed with ${books.length} books after percentage updates");
    } catch (e) {
      print("Error initializing books: $e");
      Get.snackbar('Error', 'Failed to initialize books: $e');
      if (books.isEmpty) {
        books.value = await dbHelper.getBooks();
      }
    } finally {
      isLoading.value = false;
    }
  }

  double calculateBookPercentage(Book book) {
    if (book.episodes.isEmpty) {
      print("Book '${book.title}' (ID: ${book.id}) has no episodes, returning 0%");
      return 0.0;
    }
    double totalPercentage = book.episodes.fold(0.0, (sum, episode) {
      print("Episode '${episode.localizedTitle}' (ID: ${episode.id}) percentage: ${episode.percentage}%");
      return sum + episode.percentage;
    });
    double averagePercentage = totalPercentage / book.episodes.length;
    print("Total percentage for book '${book.title}' (ID: ${book.id}): $totalPercentage, Average: $averagePercentage%");
    return averagePercentage;
  }

  void _populateCovers(List<Book> bookList) {
    for (var book in bookList) {
      backgroundCovers[book.id] = book.backgroundCover;
      coverImages[book.id] = book.coverImage;
      for (var episode in book.episodes) {
        backgroundCovers[episode.id] = episode.backgroundCover ?? 'assets/images/book/cover_image_1.svg';
        coverImages[episode.id] = episode.coverImage;
      }
    }
  }

  Book _mergeBook(Book? localBook, Book serverBook) {
    return Book(
      id: serverBook.id,
      userId: serverBook.userId,
      title: serverBook.title,
      episodes: _mergeEpisodes(localBook?.episodes ?? [], serverBook.episodes),
      coverImage: serverBook.coverImage,
      backgroundCover: localBook?.backgroundCover ?? 'assets/images/book/cover_image_1.svg',
      status: serverBook.status,
      percentage: serverBook.percentage,
      createdAt: serverBook.createdAt,
      updatedAt: serverBook.updatedAt,
    );
  }

  List<Episode> _mergeEpisodes(List<Episode> localEpisodes, List<Episode> serverEpisodes) {
    return serverEpisodes.map((serverEpisode) {
      final localEpisode = localEpisodes.firstWhereOrNull((e) => e.id == serverEpisode.id);
      return Episode(
        id: serverEpisode.id,
        bookId: serverEpisode.bookId,
        title: serverEpisode.title,
        coverImage: serverEpisode.coverImage,
        backgroundCover: localEpisode?.backgroundCover ?? 'assets/images/book/cover_image_1.svg',
        percentage: serverEpisode.percentage,
        conversations: serverEpisode.conversations,
        story: localEpisode?.story,
        storyId: localEpisode?.storyId,
      );
    }).toList();
  }

  Future<void> _processConversations(Book book) async {
    for (var episode in book.episodes) {
      for (var convo in episode.conversations) {
        final convoMap = convo as Map<String, dynamic>;
        final question = convoMap['question'] as String;
        final answer = convoMap['userAnswer'] as String;
        final botResponse = convoMap['botResponse'] as String;
        final storyGenerated = convoMap['storyGenerated'] as bool;
        final latestStoryId = convoMap['_id'] as String;

        final existingChatHistory = await dbHelper.getChatHistoryByQuestion(book.id, episode.id, question);
        if (existingChatHistory == null) {
          await dbHelper.insertChatHistory(book.id, episode.id, question, answer);
        }

        if (storyGenerated) {
          final existingStory = episode.story ?? '';
          if (!existingStory.contains(botResponse)) {
            final updatedStory = existingStory.isEmpty ? botResponse : '$existingStory\n\n$botResponse';
            print(':::: latestStoryId : $latestStoryId');
            final updatedEpisode = episode.copyWith(story: updatedStory, storyId: latestStoryId);
            await dbHelper.updateEpisode(updatedEpisode);
            final bookIndex = books.indexWhere((b) => b.id == book.id);
            if (bookIndex != -1) {
              final episodeIndex = books[bookIndex].episodes.indexWhere((e) => e.id == episode.id);
              if (episodeIndex != -1) {
                books[bookIndex].episodes[episodeIndex] = updatedEpisode;
              }
            }
          }
        }
      }
    }
  }

  void updateSelectedCover(String id, String cover) {
    backgroundCovers[id] = cover;
  }

  void updateCoverImage(String id, String imagePath, {bool isEpisode = false}) {
    coverImages[id] = imagePath;
    if (!isEpisode) {
      bookCoverImage.value = imagePath;
    }
    print("Updated cover image for ${isEpisode ? 'episode' : 'book'} ID $id: $imagePath");
  }

  void updateBookTitle(String id, String newTitle) {
    final bookIndex = books.indexWhere((b) => b.id == id);
    if (bookIndex != -1) {
      books[bookIndex] = books[bookIndex].copyWith(title: newTitle);
      books.refresh();
    }
  }

  void updateEpisodeTitle(String id, Map<String, String> newTitle) {
    for (var book in books) {
      final episodeIndex = book.episodes.indexWhere((e) => e.id == id);
      if (episodeIndex != -1) {
        book.episodes[episodeIndex] = book.episodes[episodeIndex].copyWith(title: newTitle);
        books.refresh();
        break;
      }
    }
  }

  String getBackgroundCover(String id) {
    return backgroundCovers[id] ?? 'assets/images/book/cover_image_1.svg';
  }

  String getCoverImage(String id, String defaultImage, {bool isEpisode = false}) {
    if (isEpisode) {
      final episodeImage = coverImages[id] ?? defaultImage;
      print("getCoverImage for episode ID $id: $episodeImage");
      return episodeImage;
    }
    final bookImage = coverImages[id] ?? defaultImage;
    print("getCoverImage for book ID $id: $bookImage");
    return bookImage;
  }

  String getTitle(String id) {
    final book = books.firstWhereOrNull((b) => b.id == id);
    if (book != null) return book.title;
    for (var b in books) {
      final episode = b.episodes.firstWhereOrNull((e) => e.id == id);
      if (episode != null) return episode.localizedTitle;
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
    print("Database updated for bookId: $bookId with title: ${updatedBook.title}, coverImage: ${updatedBook.coverImage}");
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
        print("Database updated for episodeId: $episodeId with title: ${updatedEpisode.localizedTitle}, coverImage: ${updatedEpisode.coverImage}");
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
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await initializeBooks();
        Get.snackbar('Success', 'Successfully created the book');
        //Get.offAll(const DashboardView(index: 1));
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
          final compositeKey = "$episodeId-${episode.localizedTitle}";
          final newCoverImagePath = coverImages[compositeKey] ?? episode.coverImage;
          print("Updating episode $episodeId - compositeKey: $compositeKey, newCoverImagePath: $newCoverImagePath");

          await updateEpisodeInDb(episodeId);

          if (newCoverImagePath.isNotEmpty && newCoverImagePath != episode.coverImage) {
            final coverImage = XFile(newCoverImagePath);
            print("Uploading coverImage for episode: $newCoverImagePath, bookId: ${book.id}, episodeNumber: $episodeNumber");

            final response = await apiService.updateEpisodeCover(book.id, coverImage, episodeNumber);
            print('Status Code: ${response.statusCode}');
            print('Body: ${response.body}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              Get.snackbar('Success', 'Episode cover updated successfully');
              Get.back();
            } else {
              Get.snackbar('Error', 'Failed to update episode cover: ${response.body}');
            }
          } else {
            print("No new cover image or image unchanged, saved locally");
            Get.snackbar('Success', 'Episode updated locally');
            Get.back();
          }
          break;
        }
      }
      if (books.every((book) => book.episodes.every((e) => e.id != episodeId))) {
        print("Episode $episodeId not found in any book");
        Get.snackbar('Error', 'Episode not found');
      }
    } catch (e) {
      print("Error updating episode cover: $e");
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
        if (bookCoverImage.value.isNotEmpty && bookCoverImage.value != book.coverImage) {
          coverImage = XFile(bookCoverImage.value);
          print("Sending coverImage for book: ${bookCoverImage.value}");
        } else {
          print("No new coverImage for book, saving locally");
        }
        final response = await apiService.updateBookCover(id, bookTitle, coverImage);
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          await _updateBookInDb(id);
          Get.snackbar('Success', 'Book cover updated successfully');
          Get.back();
          bookCoverImage.value = '';
        } else {
          Get.snackbar('Error', 'Failed to update book cover: ${response.body}');
          await _updateBookInDb(id);
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
    Map<String, String>? title,
    String? coverImage,
    String? backgroundCover,
    double? percentage,
    List<dynamic>? conversations,
    String? story,
    String? storyId,
  }) {
    return Episode(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      percentage: percentage ?? this.percentage,
      conversations: conversations ?? this.conversations,
      story: story ?? this.story,
      storyId: storyId ?? this.storyId,
    );
  }
}