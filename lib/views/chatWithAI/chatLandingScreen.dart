import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/book/addBook.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';

import '../../constants/color/app_colors.dart';
import '../../controllers/chat/botLanding_controller.dart';
import 'chatScreen.dart';

class ChatLandingScreen extends StatelessWidget {
  final BotController controller = Get.put(BotController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Bot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, and welcome!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,color: AppColors.bookTextColor),
            ),
            const SizedBox(height: 28),
            //CustomButton(text: 'Add Book', onPressed: ()=> Get.to(() => const AddBook())),
            const SizedBox(height: 28),
            const Text(
              'I’m here to help you create a beautiful memoir of your life. 😊',
              style: TextStyle(fontSize: 16,color: AppColors.botTextColor2),
            ),
            const SizedBox(height: 28),
            // Book Selection Dropdown
            const Text(
              'Select a book',
              style: TextStyle(fontSize: 18, color: AppColors.botTextColor),
            ),
            const SizedBox(height: 8),
            Obx(() => DropdownButton<String>(
              value: controller.selectedBook.value.isEmpty
                  ? null
                  : controller.selectedBook.value,
              hint: const Text('Select a book'),
              items: controller.books.map((String book) {
                return DropdownMenuItem<String>(
                  value: book,
                  child: Text(book),
                );
              }).toList(),
              onChanged: (selectedBook) {
                if (selectedBook != null) {
                  controller.selectBook(selectedBook);
                }
              },
            )),
            Obx(() {
              if (controller.selectedBook.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Select an episode',
                    style: TextStyle(
                        fontSize: 18, color: AppColors.botTextColor),
                  ),
                  const SizedBox(height: 8),
                  // Episode Selection Dropdown
                  DropdownButton<String>(
                    value: controller.selectedEpisode.value.isEmpty
                        ? null
                        : controller.selectedEpisode.value,
                    hint: const Text('Select an episode'),
                    items: controller.episodes.map((String episode) {
                      return DropdownMenuItem<String>(
                        value: episode,
                        child: Text(episode),
                      );
                    }).toList(),
                    onChanged: (selectedEpisode) {
                      if (selectedEpisode != null) {
                        controller.selectEpisode(selectedEpisode);
                        Get.off(() => const ChatScreen());
                        /*Get.snackbar(
                          'Selection',
                          'You selected "$selectedEpisode" from "${controller.selectedBook.value}"',
                          snackPosition: SnackPosition.BOTTOM,
                        );*/
                      }
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
