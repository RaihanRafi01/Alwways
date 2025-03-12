import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import '../../constants/color/app_colors.dart';
import '../../widgets/book/bookCover.dart';
import '../../widgets/customAppBar.dart';

class BookCoverEditScreen extends StatelessWidget {
  final String title;
  final String image;
  final String bookId;

  const BookCoverEditScreen({
    super.key,
    required this.title,
    required this.image,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    final BookController bookController = Get.find<BookController>();

    // Initialize controller with the book's current title
    final TextEditingController titleController = TextEditingController(text: bookController.getTitle(bookId));

    // Sync controller with book's title reactively
    ever(bookController.books, (_) {
      final currentTitle = bookController.getTitle(bookId);
      if (titleController.text != currentTitle) {
        titleController.text = currentTitle;
      }
    });

    return Scaffold(
      appBar: const CustomAppbar(title: "Edit Cover", showIcon: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                  child: Obx(
                        () => BookCover(
                      isGrid: false,
                      isCoverEdit: true,
                      title: bookController.getTitle(bookId),
                      coverImage: bookController.getCoverImage(bookId, image),
                      bookId: bookId,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: CustomTextField(
                    controller: titleController,
                    suffixIcon: Icons.edit,
                    radius: 20,
                    onChanged: (value) {
                      bookController.updateTitle(bookId, value);
                    },
                    label: '',
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Select Cover',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookController.bookCovers.length,
                    itemBuilder: (context, index) {
                      final bookCover = bookController.bookCovers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            bookController.updateSelectedCover(bookId, bookCover);
                          },
                          child: Obx(() {
                            bool isSelected = bookCover == bookController.getBackgroundCover(bookId);
                            return Stack(
                              children: [
                                SvgPicture.asset(
                                  bookCover,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/images/book/tic_icon.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => Center(
                  child: ElevatedButton(
                    onPressed: bookController.isLoading.value
                        ? null
                        : () => bookController.updateBookCoverApi(bookId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: bookController.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}