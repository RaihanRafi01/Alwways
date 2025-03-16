import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/widgets/chat/messageInput.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController messageController = Get.put(MessageController());
    final ScrollController scrollController = ScrollController();

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

    return Scaffold(
      backgroundColor: Colors.white,
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
          MessageInput(), // Assuming this is your input widget
        ],
      ),
    );
  }
}