import 'package:get/get.dart';

class BookController extends GetxController {
  var title = "My Life".obs; // Observable title

  void updateTitle(String newTitle) {
    title.value = newTitle;
  }
}