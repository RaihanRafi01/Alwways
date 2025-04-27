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
  bool _isSaving = false;

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

  void _saveChanges() {
    setState(() {
      _isSaving = true;
    });
    _performSave().then((_) {
      setState(() {
        _isSaving = false;
      });
    });
  }

  Future<void> _performSave() async {
    try {
      if (_contentController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Content cannot be empty');
        return;
      }
      await controller.updateChapterContent(
        widget.index,
        _contentController.text.trim(),
      );
      await controller.updateChapterTitle(
        widget.index,
        _titleController.text.trim(),
      );
      await controller.loadStory(
        controller.bookId!,
        controller.episodeId!,
        controller.allPageImages[0] ?? '',
      );
      Get.back(result: {
        "title": _titleController.text.trim(),
        "content": _contentController.text.trim(),
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to save changes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "edit_memory".tr,
        isEdit: true,
      ),
      body: Container(
        color: AppColors.bookBackground,
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "chapter_title".tr,
                    hintText: "enter_chapter_title".tr,
                  ),
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "chapter_content".tr,
                      hintText: "edit_content_hint".tr,
                    ),
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 16.0),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "save".tr,
                        onPressed: _isSaving ? (){} : _saveChanges,
                        isEditPage: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isSaving)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}