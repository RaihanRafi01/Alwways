import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/chat/botLanding_controller.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/widgets/chat/messageInput.dart';

import '../../constants/color/app_colors.dart';

class ChatScreen extends StatelessWidget {
  final String bookId;
  final String sectionId;
  final String episodeId;

  const ChatScreen({
    super.key,
    required this.bookId,
    required this.sectionId,
    required this.episodeId,
  });

  @override
  Widget build(BuildContext context) {
    final MessageController messageController = Get.put(MessageController());
    final BotController botController = Get.find<BotController>();
    final ScrollController scrollController = ScrollController();

    print('::::::::::::::: GGG ::::::::::::::::::::::: book id : $bookId , sectionId : $sectionId , episodeId : $episodeId');

    // Initialize chat history and questions
    void initializeChat() async {
      // Set selected IDs in BotController
      botController.selectBook(bookId);
      botController.selectSection(sectionId); // This also sets episodeId

      // Override sectionId with episodeId for chat history in MessageController
      botController.selectedSectionId.value = episodeId;

      // Fetch initial data via MessageController's onInit
      // Since MessageController fetches history and questions in onInit,
      // we rely on its existing logic but ensure it uses episodeId
    }

    // Scroll to bottom when messages change
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

    // Call initialization when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeChat();
    });

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: scrollController,
                itemCount: messageController.messages.length,
                itemBuilder: (context, index) {
                  return messageController.messages[index];
                },
              ),
            )),
          ),
          MessageInput(), // Your existing MessageInput widget
        ],
      ),
    );
  }
}