import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/book/bookChapter_controller.dart';
import '../../widgets/authentication/custom_button.dart';
import '../../widgets/customAppBar.dart';

class BookEditPage extends StatefulWidget {
  final String chapterTitle;
  final String chapterContent;
  final int index;
  final bool isCover;

  const BookEditPage({
    super.key,
    required this.index,
    required this.chapterTitle,
    required this.chapterContent,
    this.isCover = false,
  });

  @override
  _BookEditPageState createState() => _BookEditPageState();
}

class _BookEditPageState extends State<BookEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final BookChapterController controller = Get.find<BookChapterController>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapterTitle);
    _contentController = TextEditingController(text: widget.chapterContent);
  }

  @override
  void dispose() {
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
        color: AppColors.bookBackground,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Edit the content here...",
                ),
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Save",
                    onPressed: () async {
                      await controller.updateChapterContent(widget.index, _contentController.text.trim());
                      Get.back();
                    },
                    isEditPage: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
