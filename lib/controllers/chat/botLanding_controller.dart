import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';

class BotController extends GetxController {
  var selectedBook = ''.obs;
  var selectedEpisode = ''.obs;

  late final BookController bookController;

  @override
  void onInit() {
    super.onInit();
    // Inject BookController
    bookController = Get.find<BookController>();
  }

  // Dynamically get book titles from BookController
  List<String> get books => bookController.books.map((book) => book.title).toList();

  // Dynamically get episodes for the selected book
  Map<String, List<String>> get episodesByBook {
    final Map<String, List<String>> episodesMap = {};
    for (var book in bookController.books) {
      episodesMap[book.title] = book.episodes.map((episode) => episode.title).toList();
    }
    return episodesMap;
  }

  // Get episodes for the currently selected book
  List<String> get episodes => episodesByBook[selectedBook.value] ?? [];

  void selectBook(String bookTitle) {
    selectedBook.value = bookTitle;
    selectedEpisode.value = ''; // Reset selected episode when book changes
  }

  void selectEpisode(String episodeTitle) {
    selectedEpisode.value = episodeTitle;
  }
}