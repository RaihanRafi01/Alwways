import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/book/bookChapter_controller.dart';

class BookEditScreen extends StatelessWidget {
  final int index;
  final ChapterController chapterController;

  BookEditScreen({required this.index, required this.chapterController});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = chapterController.bookChapter[index];
    contentController.text = chapterController.bookContent[index];

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Chapter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Chapter Title"),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Chapter Content"),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                chapterController.updateChapter(index, titleController.text, contentController.text);
                Get.back();
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
