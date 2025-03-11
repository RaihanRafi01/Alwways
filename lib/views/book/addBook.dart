import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/book/book_controller.dart';

class AddBook extends StatelessWidget {
  const AddBook({super.key});

  @override
  Widget build(BuildContext context) {
     // Initialize the BookController
    final controller = Get.put(BookController());

    return Scaffold(
      appBar: const CustomAppbar(title: "Create a Book", showIcon: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                label: "Book Name",
                controller: controller.bookNameController, // Link to controller
                textColor: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          text: "create",
          onPressed: () {
            controller.createBook(); // Call the createBook method
          },
        ),
      ),
    );
  }
}