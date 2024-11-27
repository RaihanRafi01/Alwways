import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/book/bookCard.dart';

import 'bookCover.dart';

class Bookcoveredit extends StatefulWidget {
  const Bookcoveredit({super.key});

  @override
  State<Bookcoveredit> createState() => _BookcovereditState();
}

class _BookcovereditState extends State<Bookcoveredit> {
  final BookController bookController = Get.put(BookController());
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: bookController.title.value);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 50, right: 50, top: 10),
              child: BookCover(isGrid: false,isCoverEdit: true,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: CustomTextField(
                controller: titleController,
                suffixIcon: Icons.edit,
                radius: 20,
                onChanged: (value) {
                  bookController.updateTitle(value);
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
              height: 120, // Set height for the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bookController.bookCovers.length,
                itemBuilder: (context, index) {
                  final bookCover = bookController.bookCovers[index];
                  // Instead of checking `isSelected` here, we move the `Obx` logic to wrap this part
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
                            // Display the checkmark only if selected
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
                                    width: 20, // Adjust size of checkmark
                                    height: 20, // Adjust size of checkmark
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
          ],
        ),
      ),
    );
  }
}
