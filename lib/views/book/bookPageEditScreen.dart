import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/customAppBar.dart';

import '../../constants/color/app_colors.dart';
import '../../controllers/book/bookChapter_controller.dart';

class BookEditPage extends StatefulWidget {
  final String chapterTitle;
  final String chapterContent;
  final int index;

  const BookEditPage({
    super.key,
    required this.index,
    required this.chapterTitle,
    required this.chapterContent,
  });

  @override
  _BookEditPageState createState() => _BookEditPageState();
}

class _BookEditPageState extends State<BookEditPage> {
  late TextEditingController _titleController; // Controller for chapter title
  late TextEditingController _contentController; // Controller for chapter content

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the initial title and content
    _titleController = TextEditingController(text: widget.chapterTitle);
    _contentController = TextEditingController(text: widget.chapterContent);
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Edit Memory",
        isEdit: true,
      ),
      body: Container(
        color: AppColors.bookBackground, // Background color
        padding: const EdgeInsets.all(16.0), // Padding around content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
          children: [
            // Title TextField (Editable title)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0), // Add spacing below title
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter the chapter title...",
                ),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Content TextField (Editable content)
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Edit the content here...",
                ),
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Save Button
            CustomButton(
              text: "Save",
              onPressed: () {
                final controller = Get.find<BookChapterController>();
                // Update the chapter title and content using the controller
                controller.updateChapterTitle(widget.index, _titleController.text.trim());
                controller.updateChapterContent(widget.index, _contentController.text.trim());
                print('Title and content updated successfully!');
                // Optionally, navigate back after saving
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
