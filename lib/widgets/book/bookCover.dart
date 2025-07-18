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
  final bool isEpisode;
  final bool haveTitle;
  final Function(String)? onImagePicked; // Callback for image pick

  const BookCover({
    Key? key,
    this.haveTitle = false,
    required this.isGrid,
    this.isEdit = false,
    this.isCoverEdit = false,
    required this.title,
    required this.coverImage,
    required this.bookId,
    required this.isEpisode,
    this.onImagePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookController bookController = Get.find<BookController>();

    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final uniqueId = isEpisode ? "$bookId-$title" : bookId;
        bookController.updateCoverImage(
          uniqueId,
          pickedFile.path,
          isEpisode: isEpisode,
        );
        print("Picked image path for ${isEpisode ? 'episode' : 'book'}: ${pickedFile.path}");
        if (onImagePicked != null) {
          onImagePicked!(pickedFile.path); // Trigger callback
        }
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          final coverPath = bookController.getBackgroundCover(bookId);
          return SvgPicture.asset(
            coverPath.isNotEmpty ? coverPath : 'assets/images/book/cover_image_1.svg',
            height: isGrid ? 300 : 350,
            width: double.infinity,
            fit: BoxFit.fill,
          );
        }),
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !haveTitle
                  ? Obx(() => Text(
                bookController.getTitle(bookId).isNotEmpty
                    ? bookController.getTitle(bookId)
                    : title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isGrid ? 14 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ))
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 130),
                    child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                    color: Colors.white,
                    fontSize: isGrid ? 14 : 24,
                    fontWeight: FontWeight.bold,
                                    ),
                                  ),
                  ),
              const SizedBox(height: 4),
              SvgPicture.asset(
                "assets/images/book/book_underline_1.svg",
                width: isGrid ? 80 : 120,
              ),
              const SizedBox(height: 10),
              Obx(() {
                final selectedImage = bookController.getCoverImage(
                  isEpisode ? "$bookId-$title" : bookId,
                  coverImage,
                  isEpisode: isEpisode,
                );
                print("BookCover - Displaying image: '$selectedImage'");
                if (selectedImage.startsWith('http')) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        selectedImage,
                        height: isGrid ? 90 : 172,
                        width: isGrid ? 70 : 142,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  );
                } else if (selectedImage.endsWith('.png') || selectedImage.endsWith('.jpg')) {
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
                        final selectedImage = bookController.getCoverImage(
                          isEpisode ? "$bookId-$title" : bookId,
                          coverImage,
                          isEpisode: isEpisode,
                        );
                        final isImageSelected =
                            selectedImage.endsWith('.png') || selectedImage.endsWith('.jpg');
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
        ),
        if (isEdit)
          Positioned(
            right: 10,
            bottom: 10,
            child: GestureDetector(
              onTap: () {
                print("Navigating to edit screen - bookId: $bookId, isEpisode: $isEpisode");
                Get.to(BookCoverEditScreen(
                  title: title,
                  image: coverImage,
                  bookId: bookId,
                  isEpisode: isEpisode,
                ));
              },
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