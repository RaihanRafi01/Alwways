import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/book/allEpisodes_controller.dart'; // Import AllEpisodesController
import '../../widgets/authentication/custom_button.dart';
import '../../widgets/customAppBar.dart';

class BookEditPage extends StatefulWidget {
  final int episodeIndex; // Add episodeIndex
  final int index;
  final String chapterTitle;
  final String chapterContent;
  final bool isCover;

  const BookEditPage({
    super.key,
    required this.episodeIndex, // Add episodeIndex
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
  final AllEpisodesController controller = Get.find<AllEpisodesController>(); // Use AllEpisodesController
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
        return;
      }
      print("Saving changes for episode ${widget.episodeIndex}, page ${widget.index}");
      await controller.updateChapterContent(
        widget.episodeIndex,
        widget.index,
        _contentController.text.trim(),
      );
      await controller.updateChapterTitle(
        widget.episodeIndex,
        widget.index,
        _titleController.text.trim(),
      );
      Get.back(result: {
        "title": _titleController.text.trim(),
        "content": _contentController.text.trim(),
      });
    } catch (e) {
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
                        onPressed: _isSaving ? () {} : _saveChanges,
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