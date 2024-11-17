import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/widgets/chat/bookPreview.dart';
import 'package:playground_02/widgets/chat/botMessage.dart';
import 'package:playground_02/widgets/customAppBar.dart';
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
      backgroundColor: AppColors.appBackground,
      appBar: const CustomAppbar(title: "AI Bot",),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView(
              controller: scrollController, // Attach the ScrollController
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text("Hello, and welcome!",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                const BookPreview(bookTitle: 'My Life', svgPath: 'assets/images/book/book_underline_1_rotate.svg'),
                const BotMessage(message: "I’m here to help you create a beautiful memoir of your life. 😊"),
                const SizedBox(height: 20),
                const BotMessage(message: "We’ll go through some questions, and you can share as much or as little as you’d like. Think of me as a guide, helping you capture your most meaningful memories.\nLet’s start with something simple. Can you tell me a little about where you grew up?"),
                ...controller.messages, // Display all messages dynamically
                const SizedBox(height: 20),
              ],
            )),
          ),
           MessageInput(),
        ],
      ),
    );
  }
}
