import 'package:get/get.dart';

import '../../../controllers/book/book_controller.dart';
import '../../../controllers/chat/botLanding_controller.dart';

class DashboardController extends GetxController {
  final BookController bookController = Get.put(BookController());
  final BotController botController = Get.put(BotController());

  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
   botController.fetchSections();
  }

  void updateIndex(int index) {
    print("Updating index to $index"); // Debugging
    currentIndex.value = index;
  }
}
