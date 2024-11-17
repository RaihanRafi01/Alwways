import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/book/book_controller.dart';

class BookCover extends StatelessWidget {
  final bool isGrid;
  final bool isEdit;

  const BookCover({
    Key? key,
    required this.isGrid,
    this.isEdit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();

    // Function to pick an image
    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
      await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        bookController.updateSelectedCoverImage(pickedFile.path); // Update the cover
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Book Cover Background
        Obx(() {
          // Check if a PNG/JPG or SVG is selected
          final coverPath = bookController.selectedCover.value;
          if (coverPath.endsWith('.png') || coverPath.endsWith('.jpg')) {
            // Display uploaded PNG/JPG from file
            return Image.file(
              File(coverPath),
              height: isGrid ? 300 : 350,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          } else {
            // Display default or selected SVG
            return SvgPicture.asset(
              coverPath.isNotEmpty
                  ? coverPath
                  : 'assets/images/book/cover_image_1.svg', // Default SVG cover
              height: isGrid ? 300 : 350,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          }
        }),
        // Book Title and Underline
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
              bookController.title.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isGrid ? 14 : 24,
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox(height: 4),
            SvgPicture.asset(
              "assets/images/book/book_underline_1.svg",
              width: isGrid ? 80 : 120,
            ),
            const SizedBox(height: 10),
            Obx(() {
              final selectedImage =
                  bookController.selectedCoverImage.value;
              if (selectedImage.isNotEmpty) {
                // Show image only if selectedCoverImage is not empty
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(selectedImage),
                      height: isGrid ? 90 : 172,
                      width: isGrid ? 70 : 142,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink(); // Hide if no image selected
            }),
            // Conditional UI for editing or adding
            if (isEdit)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Add/Edit button
                  GestureDetector(
                    onTap: _pickImage, // Call the image picker on tap
                    child: Obx(() {
                      final isImageSelected =
                          bookController.selectedCoverImage.value
                              .endsWith('.png') ||
                              bookController.selectedCoverImage.value
                                  .endsWith('.jpg');
                      return SvgPicture.asset(
                        isImageSelected
                            ? "assets/images/book/edit_icon.svg" // Edit icon after upload
                            : "assets/images/book/add_icon.svg", // Add icon before upload
                        height: 22.72,
                        width: 22.72,
                      );
                    }),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
