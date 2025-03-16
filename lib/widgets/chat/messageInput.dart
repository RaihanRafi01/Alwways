import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController controller = Get.find<MessageController>();
    final TextEditingController textController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: "Type your message..."),
              onChanged: (text) => controller.updateHasText(text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              controller.sendMessage(textController.text);
              textController.clear();
            },
          ),
        ],
      ),
    );
  }
}