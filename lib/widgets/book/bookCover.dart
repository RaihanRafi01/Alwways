import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/views/book/bookCoverEditScreen.dart';
import '../../controllers/book/book_controller.dart';

class BookCover extends StatelessWidget {
  final bool isGrid;
  final bool isEdit;
  final bool isCoverEdit;
  final String title;
  final String coverImage;
  final String bookId;

  const BookCover({
    Key? key,
    required this.isGrid,
    this.isEdit = false,
    this.isCoverEdit = false,
    required this.title,
    required this.coverImage,
    required this.bookId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookController bookController = Get.find<BookController>(); // Use Get.find()

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        bookController.updateSelectedCoverImage(pickedFile.path);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          final coverPath = bookController.selectedCover.value;
          if (coverPath.endsWith('.png') || coverPath.endsWith('.jpg')) {
            return Image.file(
              File(coverPath),
              height: isGrid ? 300 : 350,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          } else {
            return SvgPicture.asset(
              coverPath.isNotEmpty ? coverPath : 'assets/images/book/cover_image_1.svg',
              height: isGrid ? 300 : 350,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          }
        }),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isGrid ? 14 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            SvgPicture.asset(
              "assets/images/book/book_underline_1.svg",
              width: isGrid ? 80 : 120,
            ),
            const SizedBox(height: 10),
            Obx(() {
              final selectedImage = bookController.selectedCoverImage.value;
              if (selectedImage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
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
              } else if (coverImage.startsWith('http')) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      coverImage,
                      height: isGrid ? 90 : 172,
                      width: isGrid ? 70 : 142,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            if (isCoverEdit)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Obx(() {
                      final isImageSelected =
                          bookController.selectedCoverImage.value.endsWith('.png') ||
                              bookController.selectedCoverImage.value.endsWith('.jpg');
                      return SvgPicture.asset(
                        isImageSelected
                            ? "assets/images/book/edit_icon.svg"
                            : "assets/images/book/add_icon.svg",
                        height: 22.72,
                        width: 22.72,
                      );
                    }),
                  ),
                ],
              ),
          ],
        ),
        if (isEdit)
          Positioned(
            right: 6,
            bottom: 6,
            child: GestureDetector(
              onTap: () => Get.to(
                BookCoverEditScreen(title: title, image: coverImage, bookId: bookId),
              ),
              child: SvgPicture.asset(
                "assets/images/book/edit_icon.svg",
                height: 24,
                width: 24,
              ),
            ),
          ),
      ],
    );
  }
}