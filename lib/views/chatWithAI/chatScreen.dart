import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/widgets/chat/bookPreview.dart';
import 'package:playground_02/widgets/chat/chatHeader.dart';
import 'package:playground_02/widgets/chat/messageInput.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.put(MessageController());
    final ScrollController scrollController = ScrollController();

    // Ensure the ListView scrolls to the bottom when a new message is added
    controller.messages.listen((_) {
      if (scrollController.hasClients) {
        // Scroll to the bottom
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: const ChatHeader(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView(
              controller: scrollController, // Attach the ScrollController
              padding: const EdgeInsets.all(16.0),
              children: [
                const BookPreview(),
                const SizedBox(height: 20),
                ...controller.messages, // Display all messages dynamically
                const SizedBox(height: 20),
              ],
            )),
          ),
          const MessageInput(),
        ],
      ),
    );
  }
}
