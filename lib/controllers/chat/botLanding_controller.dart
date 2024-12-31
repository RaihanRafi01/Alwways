import 'package:get/get.dart';

class BotController extends GetxController {
  var selectedBook = ''.obs;
  var selectedEpisode = ''.obs;

  final List<String> books = ['My Book', 'Mother Book'];
  final Map<String, List<String>> episodesByBook = {
    'My Book': ['Childhood', 'Family', 'Friend', 'Love'],
    'Mother Book': ['Memories', 'Sacrifices', 'Happiness'],
  };

  List<String> get episodes => episodesByBook[selectedBook.value] ?? [];

  void selectBook(String book) {
    selectedBook.value = book;
    selectedEpisode.value = ''; // Reset selected episode
  }

  void selectEpisode(String episode) {
    selectedEpisode.value = episode;
  }
}