import 'package:get/get.dart';

class BookController extends GetxController {
  // Use Rx<String> to track the selected cover
  RxString selectedCover = ''.obs;  // Initialize with an empty string
  RxString selectedCoverImage = ''.obs;
  var title = 'My Life'.obs;

  // List of cover image paths
  List<String> bookCovers = [
    'assets/images/book/cover_image_1.svg',
    'assets/images/book/cover_image_2.svg',
    'assets/images/book/cover_image_3.svg',
    'assets/images/book/cover_image_1.svg',
    'assets/images/book/cover_image_2.svg',
    'assets/images/book/cover_image_3.svg',
    // Add more cover images as needed
  ];

  // Method to update the selected cover
  void updateSelectedCover(String cover) {
    selectedCover.value = cover;  // Update the selected cover
  }

  // Method to update the title
  void updateTitle(String newTitle) {
    title.value = newTitle;
  }

  // Method to update the selected cover
  void updateSelectedCoverImage(String coverPath) {
    selectedCoverImage.value = coverPath; // Update with the new cover path
  }

}
