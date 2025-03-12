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

    // Defer initial updates to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bookController.title.value != title) {
        bookController.updateTitle(title);
      }
      if (bookController.selectedCoverImage.value != image) {
        bookController.updateSelectedCoverImage(image);
      }
    });

    // Initialize TextEditingController with the passed title (not reactive yet)
    final TextEditingController titleController = TextEditingController(text: title);

    // Sync controller with observable changes
    ever(bookController.title, (newTitle) {
      if (titleController.text != newTitle) {
        titleController.text = newTitle;
      }
    });

    return Scaffold(
      appBar: const CustomAppbar(title: "Edit Cover", showIcon: false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
              child: Obx(
                    () => BookCover(
                  isGrid: false,
                  isCoverEdit: true,
                  title: bookController.title.value,
                  coverImage: bookController.selectedCoverImage.value.isNotEmpty
                      ? bookController.selectedCoverImage.value
                      : image,
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
                  bookController.updateTitle(value); // Update on user input
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
                        bookController.updateSelectedCover(bookCover);
                      },
                      child: Obx(() {
                        bool isSelected = bookCover == bookController.selectedCover.value;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: ElevatedButton(
                onPressed: () {
                  bookController.updateBookCoverApi(bookId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}