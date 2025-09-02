import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/auth_controller.dart';
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
  final AuthController authController = Get.find<AuthController>();
  late var isFree = 'Free'; // Default to 'Free'

  @override
  Widget build(BuildContext context) {
    // Only update isFree if subscriptionType has a value
    if (authController.subscriptionType.value.isNotEmpty) {
      isFree = authController.subscriptionType.value;
    }
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        title: Text("ai_bot".tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // If a book is already selected, skip initial chat
          if (controller.selectedBookId.value.isNotEmpty) {
            return _buildRegularLandingScreen(context);
          } else if (controller.books.isEmpty) {
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
          /*CustomButton(
            text: "add_book".tr,
            onPressed: () => Get.to(() => const AddBook()),
          ),
          const SizedBox(height: 28),*/
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
                      child: Text(section.localizedName), // Fix 1: Use localizedName
                    );
                  }).toList(),
                  onChanged: (selectedSectionId) {
                    if (selectedSectionId != null && selectedSectionId.isNotEmpty) {
                      // Check subscription status and section position
                      final sectionIndex = controller.sections.indexWhere((section) => section.id == selectedSectionId);

                      if (isFree == 'Free' && sectionIndex > 2) { // Index > 2 means 4th section or beyond
                        Get.snackbar(
                          "upgrade_required".tr,
                          "upgrade_message".tr,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                      } else {
                        controller.selectSection(selectedSectionId);
                        Get.off(() => ChatScreen(
                          bookId: controller.selectedBookId.value,
                          sectionId: controller.selectedSectionId.value,
                          episodeId: controller.selectedEpisodeId.value, // Fix 3: Use selectedEpisodeId
                        ));
                      }
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
      final lang = Get.locale?.languageCode ?? 'en'; // Get current language
      messageController.questionController.questions.value = [
        Question(
          id: "2",
          episodeId: '',
          sectionId: 'initial',
          text: {lang: "question_2".tr}, // "What is your name?"
          v: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        Question(
          id: "3",
          episodeId: '',
          sectionId: 'initial',
          text: {lang: "question_3".tr}, // "What title would you like to give the book? ..."
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
          style: const TextStyle(fontSize: 18, color: AppColors.textColor),
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