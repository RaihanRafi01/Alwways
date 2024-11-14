import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';

import 'bookCard.dart';

class Bookcoveredit extends StatefulWidget {
  const Bookcoveredit({super.key});

  @override
  State<Bookcoveredit> createState() => _BookcovereditState();
}

class _BookcovereditState extends State<Bookcoveredit> {
  final BookController bookController = Get.put(BookController()); // Initialize the controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 50, right: 50, top: 10),
              child: BookCover(isGrid: false),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Obx(() => CustomTextField(
                label: bookController.title.value,
                suffixIcon: Icons.edit,
                radius: 20,
                onChanged: (value) {
                  bookController.updateTitle(value); // Update title in controller
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
