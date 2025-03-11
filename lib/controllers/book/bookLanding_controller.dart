import 'package:get/get.dart';

import '../../services/api_service/api_service.dart';
import '../../services/model/bookModel.dart';

class BookLandingController extends GetxController {
  var books = <Book>[].obs; // Observable list of books
  var isLoading = true.obs; // Loading state

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      isLoading(true);
      final fetchedBooks = await ApiService().getAllBooks();
      books.assignAll(fetchedBooks);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load books: $e');
    } finally {
      isLoading(false);
    }
  }
}