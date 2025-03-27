import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/views/book/addBook.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/chat/messageInput.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/chat/botLanding_controller.dart';
import '../../controllers/chat/message_controller.dart';
import '../../services/model/bookModel.dart';
import 'chatScreen.dart';

class ChatLandingScreen extends StatelessWidget {
  final BotController controller = Get.put(BotController());
  final BookController bookController = Get.put(BookController());
  final MessageController messageController = Get.put(MessageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ai_bot".tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // Ensure books are loaded or refreshed when returning
          if (controller.books.isEmpty) {
            return _buildInitialChatScreen(context);
          } else {
            return _buildRegularLandingScreen(context);
          }
        }),
      ),
    );
  }

  Widget _buildRegularLandingScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "hello_and_welcome".tr,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.bookTextColor),
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: "add_book".tr,
            onPressed: () => Get.to(() => const AddBook()),
          ),
          const SizedBox(height: 28),
          Text(
            "memoir_help_message".tr,
            style: const TextStyle(fontSize: 16, color: AppColors.botTextColor2),
          ),
          const SizedBox(height: 28),
          Text(
            "select_a_book".tr,
            style: const TextStyle(fontSize: 18, color: AppColors.botTextColor),
          ),
          const SizedBox(height: 8),
          Obx(() {
            // Validate selectedBookId against available books
            final validBookId = controller.books.any((book) => book['id'] == controller.selectedBookId.value)
                ? controller.selectedBookId.value
                : null;

            return DropdownButton<String>(
              value: validBookId,
              hint: Text("select_a_book".tr),
              items: controller.books.map((Map<String, String> book) {
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
            );
          }),
          Obx(() {
            if (controller.selectedBookId.value.isEmpty) {
              return const SizedBox.shrink();
            }
            // Validate selectedSectionId against available sections
            final validSectionId = controller.sections.any((section) => section.id == controller.selectedSectionId.value)
                ? controller.selectedSectionId.value
                : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  "select_a_section".tr,
                  style: const TextStyle(fontSize: 18, color: AppColors.botTextColor),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: validSectionId,
                  hint: Text("select_a_section".tr),
                  items: controller.sections.map<DropdownMenuItem<String>>((Section section) {
                    return DropdownMenuItem<String>(
                      value: section.id,
                      child: Text(section.name),
                    );
                  }).toList(),
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
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInitialChatScreen(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    void initializeInitialChat() {
      messageController.messages.clear();
      messageController.userAnswers.clear();
      messageController.questionController.questions.value = [
        Question(
          id: "1",
          episodeId: '',
          sectionId: 'initial',
          text: "question_1".tr,
          v: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];
      messageController.questionController.currentQuestionIndex.value = 0;
      messageController.askQuestion();
    }

    ever(messageController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeInitialChat();
    });

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "answer_questions_prompt".tr,
          style: const TextStyle(fontSize: 16, color: AppColors.botTextColor2),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Obx(() => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: messageController.messages.map((message) => message).toList(),
            ),
          )),
        ),
        MessageInput(),
      ],
    );
  }
}