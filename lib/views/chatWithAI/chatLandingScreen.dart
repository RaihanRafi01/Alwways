import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/book/addBook.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/chat/botLanding_controller.dart';
import '../../services/database/databaseHelper.dart';
import '../../services/model/bookModel.dart';
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
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.bookTextColor),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Add Book',
              onPressed: () => Get.to(() => const AddBook()),
            ),
            const SizedBox(height: 28),
            const Text(
              'I’m here to help you create a beautiful memoir of your life. 😊',
              style: TextStyle(fontSize: 16, color: AppColors.botTextColor2),
            ),
            const SizedBox(height: 28),
            const Text(
              'Select a book',
              style: TextStyle(fontSize: 18, color: AppColors.botTextColor),
            ),
            const SizedBox(height: 8),
            Obx(() => DropdownButton<String>(
              value: controller.selectedBookId.value.isEmpty ? null : controller.selectedBookId.value,
              hint: const Text('Select a book'),
              items: controller.books.isEmpty
                  ? [const DropdownMenuItem<String>(value: null, child: Text('No books available'))]
                  : controller.books.map((Map<String, String> book) {
                return DropdownMenuItem<String>(
                  value: book['id'],
                  child: Text(book['title']!),
                );
              }).toList(),
              onChanged: (selectedBookId) {
                if (selectedBookId != null && selectedBookId.isNotEmpty) {
                  controller.selectBook(selectedBookId);
                }
              },
            )),
            Obx(() {
              if (controller.selectedBookId.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Select a section',
                      style: TextStyle(fontSize: 18, color: AppColors.botTextColor),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => DropdownButton<String>(
                      value: controller.selectedSectionId.value.isEmpty ? null : controller.selectedSectionId.value,
                      hint: const Text('Select a section'),
                      items: controller.episodes.isEmpty
                          ? [const DropdownMenuItem<String>(value: null, child: Text('No sections available'))]
                          : controller.sections
                          .map<DropdownMenuItem<String>>((Section section) {
                        return DropdownMenuItem<String>(
                          value: section.id,
                          child: Text(section.name),
                        );
                      })
                          .toList(),
                      onChanged: (selectedSectionId) {
                        if (selectedSectionId != null && selectedSectionId.isNotEmpty) {
                          controller.selectSection(selectedSectionId);
                          Get.off(() => ChatScreen(
                            bookId: controller.selectedBookId.value,
                            sectionId: controller.selectedSectionId.value,
                            episodeId: controller.selectedEpisodeId.value,
                          ));
                        }
                      },
                    )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}