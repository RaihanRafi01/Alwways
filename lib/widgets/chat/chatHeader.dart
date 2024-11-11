import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Get.back();
        },
      ),
      title: const Text(
        'AI bot',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            // Define edit action
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}