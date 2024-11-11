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
              controller: textController,  // Use TextEditingController to get the current input
              decoration: InputDecoration(
                hintText: 'Message',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              String currentMessage = textController.text.trim();
              if (currentMessage.isNotEmpty) {
                controller.sendMessage(currentMessage);  // Send the current message
                textController.clear();  // Clear the text field after sending
              }
            },
            child: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
